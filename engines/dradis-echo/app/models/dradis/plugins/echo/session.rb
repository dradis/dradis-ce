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

    delegate :project, to: :record

    # -- Scopes ---------------------------------------------------------------
    # Can't use where(record: record): Rails builds record_type from the
    # polymorphic_name ('Note') for an Issue, missing the forced 'Issue' rows.
    # See record_type_for / the record= override below.
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

    # Only completed turns are safe to replay to a provider: a streaming row has
    # no content yet, and a failed one carries a nil/partial body. Sending either
    # would poison the next request with a `content: nil` turn.
    def to_provider_messages
      messages.where(status: :complete).order(:created_at, :id).map do |message|
        { role: message.role, content: message.content }
      end
    end

    # FIXME - ISSUE/NOTE INHERITANCE
    #
    # Because Issue descends from Note but doesn't use STI, Rails's default
    # polymorphic setter stores 'Note' when you assign an Issue. Force 'Issue'
    # here so the record loads back as the right class. Mirrors
    # Comment#commentable= (app/models/comment.rb).
    def record=(new_record)
      super
      self.record_type = self.class.record_type_for(new_record) if new_record
      new_record
    end

    private

    # A crashed ReplyJob leaves the session locked in `generating`. Two shapes:
    #
    #   1. An orphaned streaming message. ReplyJob touches the streaming row as
    #      chunks arrive (a throttled liveness signal), so a message untouched
    #      past the read timeout plus a margin is genuinely dead — not a slow but
    #      live stream. Fail it and release the session.
    #   2. No streaming message at all: enqueue raised after the status commit,
    #      the worker was hard-killed before messages.create!, or the job was
    #      lost from the queue. Here the session's own updated_at is the liveness
    #      signal — once it's past the threshold, release the orphaned lock.
    def reclaim_stuck_generation!
      threshold = Provider::HttpStreaming::READ_TIMEOUT.seconds.ago - STUCK_MARGIN
      streaming = messages.where(role: :assistant, status: :streaming)
      stuck = streaming.where(updated_at: ..threshold)

      if stuck.exists?
        stuck.find_each do |message|
          message.update!(status: :failed, metadata: message.metadata.merge('error' => Message::GENERIC_ERROR))
        end
        update!(status: :idle)
      elsif streaming.none? && updated_at <= threshold
        update!(status: :idle)
      end
    end
  end
end
