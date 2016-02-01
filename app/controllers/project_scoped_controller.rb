class ProjectScopedController < AuthenticatedController
  # FIXME: re-enable Activity tracking
  # include ActivityTracking

  helper :snowcrash
  layout 'snowcrash'

  protected

  # Initialize the instance varables used in the sidebar for nodes pages
  # (@sorted_evidence and @sorted_notes, displayed in
  # `nodes/_sidebar.html.erb`.
  #
  # Used in node, evidence, note, and revision controllers.
  def initialize_nodes_sidebar
    @issues          = Issue.where(node_id: Node.issue_library.id).sort
    # If you just tried to save an invalid Note, then that Note will be
    # included in @node.notes and will crash the sidebar (because the sidebar
    # won't be able to generate a route for a Note with no id) So filter out
    # Notes that haven't been saved:
    @sorted_notes    = @node.notes.sort_by(&:title).select(&:persisted?)
    @sorted_evidence = @node.evidence.sort_by { |e1| e1.issue.title }
  end

end
