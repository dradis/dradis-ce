module Dradis::Plugins::Echo
  class Session < ApplicationRecord
    # Beyond the provider read timeout a still-streaming message can only be the
    # debris of a crashed job, so we allow this much slack before reclaiming it.
    STUCK_MARGIN = 30.seconds

    enum :status, %i[idle generating], default: :idle

    # -- Relationships --------------------------------------------------------
    belongs_to :agent
    belongs_to :record, polymorphic: true
    belongs_to :user, optional: true
    has_many :messages, dependent: :destroy

    # -- Scopes ---------------------------------------------------------------
    scope :for_record, ->(record) {
      where(record_type: record_type_for(record), record_id: record.id)
    }

    # -- Class Methods --------------------------------------------------------

    # Mirrors the record= override below: Issues are stored as 'Issue' even
    # though they descend from Note, so scopes must resolve the same type.
    def self.record_type_for(record)
      record.is_a?(Issue) ? 'Issue' : record.class.base_class.name
    end

    # -- Instance Methods -----------------------------------------------------
    # Broadcasts the composer partial so the browser reflects the current
    # idle/generating state. Called on every idle<->generating transition.
    def broadcast_composer_state
      broadcast_replace_to(
        [self, :composer_state],
        target: ActionView::RecordIdentifier.dom_id(self, :composer_state),
        partial: 'dradis/plugins/echo/projects/sessions/composer_state',
        locals: { session: self }
      )
    end

    def project
      record.project
    end

    # The gate in front of ReplyJob: flips idle->generating and enqueues exactly
    # one job. A no-op while already generating, so repeated calls (a user
    # sending several messages) never double-enqueue — the running job re-checks
    # for newer messages when it finishes. A generation whose streaming message
    # has gone stale is treated as dead and reclaimed first.
    def request_reply!
      enqueue = false

      with_lock do
        reclaim_stuck_generation! if generating?

        if idle?
          update!(status: :generating)
          broadcast_composer_state
          enqueue = true
        end
      end

      ReplyJob.perform_later(self) if enqueue
    end

    def to_provider_messages
      messages.order(:created_at, :id).map do |message|
        { role: message.role, content: message.content }
      end
    end

    # Because Issue descends from Note but doesn't use STI, Rails's default
    # polymorphic setter stores 'Note' when you assign an Issue. Force 'Issue'
    # here so the record loads back as the right class. Mirrors
    # Comment#commentable= (app/models/comment.rb).
    #
    # FIXME - ISSUE/NOTE INHERITANCE
    def record=(new_record)
      super
      self.record_type = 'Issue' if new_record.is_a?(Issue)
      new_record
    end

    private

    # A crashed ReplyJob leaves the session locked in `generating` with an
    # orphaned streaming message. Once that message hasn't been touched past the
    # provider read timeout (plus a margin), fail it and release the session so
    # the next request_reply! can start fresh.
    def reclaim_stuck_generation!
      threshold = Provider::HttpStreaming::READ_TIMEOUT.seconds.ago - STUCK_MARGIN
      stuck = messages.where(role: :assistant, status: :streaming).where(updated_at: ..threshold)
      return unless stuck.exists?

      stuck.find_each do |message|
        message.update!(status: :failed, metadata: message.metadata.merge('error' => 'interrupted'))
      end
      update!(status: :idle)
    end
  end
end
