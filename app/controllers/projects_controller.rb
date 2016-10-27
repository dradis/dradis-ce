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
    @taggings_by_tag = Tagging.group(:tag_id).count
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

  end
end
