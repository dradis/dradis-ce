module ProjectScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_project

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
    { project_id: @project.id } if @project
  end

  def set_project
    @nodes   = Node.in_tree
    @project = Project.new
  end
end
