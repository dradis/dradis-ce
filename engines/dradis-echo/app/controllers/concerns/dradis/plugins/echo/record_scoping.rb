module Dradis::Plugins::Echo
  # Shared record scoping for the session controllers. A session is always
  # anchored to a record (an Issue or a Note) that must live inside the current
  # project; resolving it through the project's collections gives us
  # cross-project/record isolation for free — an out-of-scope id raises
  # ActiveRecord::RecordNotFound, mirroring Projects::GrammarController.
  module RecordScoping
    extend ActiveSupport::Concern

    private

    def scoped_record(record)
      collection = record.is_a?(Issue) ? current_project.issues : current_project.notes
      collection.find(record.id)
    end
  end
end
