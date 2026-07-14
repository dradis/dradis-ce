module Dradis::Plugins::Echo
  class Session < ApplicationRecord
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
    def project
      record.project
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
  end
end
