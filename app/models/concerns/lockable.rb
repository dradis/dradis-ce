module Lockable
  extend ActiveSupport::Concern

  mattr_accessor :allowed_types, default: []

  included do |base|
    Lockable.allowed_types << base.name

    has_many :editing_sessions, as: :record

    # FIXME - ISSUE/NOTE INHERITANCE
    # We can't rely on `dependent: :destroy` above: for models that descend
    # from another AR class (see Issue) it would look for sessions with the
    # base class' name in record_type and silently leave orphans behind.
    # EditingSession.for_record uses the record's actual class instead.
    before_destroy :destroy_editing_sessions
  end

  def acquire_edit_session(user)
    EditingSession.acquire!(record_type: self.class.name, record_id: id, user: user)
  end

  def destroy_editing_sessions
    EditingSession.for_record(self)&.destroy
  end

  def release_edit_session(user)
    session = EditingSession.for_record(self)
    session.destroy if session&.user == user
  end
end
