module ProjectScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_project
    before_action :set_nodes

    helper :snowcrash
    layout 'snowcrash'
  end

  protected

  # Internal: Sets saves the current :project_id as PaperTrail::Version metadata
  # this is going to allow us to speed up recovery of Versions scoped to the
  # current project.
  #
  # See also:
  #
  #   https://github.com/airblade/paper_trail#metadata-from-controllers
  #
  def info_for_paper_trail
  end

  # Initialize the instance varables used in the sidebar for nodes pages
  # (@sorted_evidence and @sorted_notes, displayed in
  # `nodes/_sidebar.html.erb`.
  #
  # Used in node, evidence, note, and revision controllers.
  def initialize_nodes_sidebar
    # If you just tried to save an invalid Note, then that Note will be
    # included in @node.notes and will crash the sidebar (because the sidebar
    # won't be able to generate a route for a Note with no id) So filter out
    # Notes that haven't been saved:
    @sorted_notes    = @node.notes.sort_by(&:title).select(&:persisted?)
    @sorted_evidence = @node.evidence.sort_by { |e1| e1.issue.title }
  end

  def set_nodes
    @nodes = Node.in_tree
  end

  def set_project
    project
  end

  def project
    @project ||= Project.new
  end
end
