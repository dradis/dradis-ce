module Dradis::Plugins::Echo
  # Gives a record (a Note, and by inheritance an Issue) an Echo sessions
  # association that is cleaned up when the record is destroyed. Included into
  # ::Note via the engine's on_load(:note_model) hook so Issue < Note inherits
  # it; adding sessions to ContentBlock/Evidence later is a one-line include.
  #
  # Mirrors app/models/concerns/commentable.rb.
  module Sessionable
    extend ActiveSupport::Concern

    included do
      has_many :echo_sessions, as: :record,
                               class_name: 'Dradis::Plugins::Echo::Session', dependent: :destroy

      # FIXME - ISSUE/NOTE INHERITANCE
      # Mirror Note's Comment/InlineThread/Subscription sweep (note.rb): when an
      # Issue row is destroyed while loaded as a Note (e.g. a Pro project.notes
      # cascade), it loads as Note so the polymorphic `dependent: :destroy` above
      # misses its record_type: 'Issue' sessions. Do NOT guard on is_a?(Issue) --
      # the loaded-as-Note case is exactly what this catches, and it is harmless
      # for a genuine Note (a notes-row id is a Note-row or an Issue-row, never
      # both). A genuine Issue is already covered by dependent: :destroy.
      after_destroy do
        Dradis::Plugins::Echo::Session.where(record_type: 'Issue', record_id: id).destroy_all
      end
    end
  end
end
