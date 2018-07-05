module ProjectScoped
  extend ActiveSupport::Concern

  included do
    # Use prepend_before_action to keep things consistent with Pro:
    prepend_before_action :set_project
    before_action :set_nodes

    helper :snowcrash
    layout 'snowcrash'
  end

  protected

  # In Pro this method sets the column `versions.project_id`.
  #
  # See https://github.com/airblade/paper_trail#metadata-from-controllers
  #
  # Since versions.project_id doesn't exist in CE, the method is a no-op here.
  #
  # We don't strictly need to include the empty method here, but leaving it in
  # makes things clearer when dealing with CE/Pro merges in future.
  def info_for_paper_trail
  end

  def set_nodes
    @nodes = Node.in_tree
  end

  # In Pro this method will load a Project using params[:project_id]. In
  # CE things are much simpler.
  def set_project
    @project = Project.new
  end
end
