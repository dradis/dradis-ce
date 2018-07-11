class ProjectsController < AuthenticatedController
  before_action :set_project

  helper        :snowcrash
  helper_method :current_project
  layout        'snowcrash'

  def index
    redirect_to project_path(current_project)
  end

  def show
    @activities    = Activity.latest
    @authors       = [current_user]
    @issues        = Issue.where(node_id: Node.issue_library.id).includes(:tags).sort
    @methodologies = Node.methodology_library.notes.map{|n| Methodology.new(filename: n.id, content: n.text)}
    @nodes         = Node.in_tree
    @tags          = Tag.all

    @count_by_tag  = { unassigned: 0 }
    @issues_by_tag = Hash.new{|h,k| h[k] = [] }

    @tag_names = @tags.map do |tag|
      @count_by_tag[tag.name] = 0
      [tag.name, [tag.display_name, tag.color]]
    end.to_h

    @issues.each do |issue|
      if issue.tags.empty?
        @issues_by_tag[:unassigned] << issue
        @count_by_tag[:unassigned]  += 1
      else
        issue.tags.each do |tag|
          @issues_by_tag[tag.name] << issue
          @count_by_tag[tag.name]  += 1
        end
      end
    end
  end

  private
  def set_project
    current_project
  end

  def current_project
    @current_project ||= Project.new
  end
end
