module Dradis::Plugins::Echo
  # Shared record scoping for the session controllers. A session is always
  # anchored to a record (an Issue or a Note) that must live inside the current
  # project; resolving it through the project's collections gives us
  # cross-project/record isolation for free — an out-of-scope id raises
  # ActiveRecord::RecordNotFound, mirroring Projects::GrammarController.
  #
  # We read the session's stored record_type/record_id directly rather than
  # loading session.record: the association would fire a polymorphic query just
  # to re-scope through the project. Issues are persisted as 'Issue' even though
  # they descend from Note (see Session#record=), so record_type maps straight
  # onto the matching project collection (issues, notes, ...).
  module RecordScoping
    extend ActiveSupport::Concern

    private

    def scoped_record(session)
      current_project.public_send(session.record_type.underscore.pluralize).find(session.record_id)
    end
  end
end
