class ProjectsController < AuthenticatedController
  helper :snowcrash
  layout 'snowcrash'

  def show
    @nodes   = Node.in_tree
    @issues  = Issue.where(node_id: Node.issue_library.id).includes(:tags).sort
    @authors = [current_user]

    @methodologies = Node.methodology_library.notes.map{|n| Methodology.new(filename: n.id, content: n.text)}

    @tags = Tag.all
    @issues_by_tag = Hash.new{|h,k| h[k] = [] }
    assigned = nil

    @activities = Activity.latest

    @issues.each do |issue|
      assigned = false
      @tags.each do |tag|
        if issue.tags.include?(tag)
          @issues_by_tag[tag.name] << issue
          assigned = true
        end
      end
      @issues_by_tag[:unassigned] << issue unless assigned
    end

    @count_by_tag = @issues_by_tag.map do |tag, issues|
      [tag, issues.count]
    end.to_h
  end
end
