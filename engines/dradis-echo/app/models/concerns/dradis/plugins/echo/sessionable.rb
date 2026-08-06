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
    end
  end
end
