class ProjectsController < AuthenticatedController
  helper :snowcrash
  layout 'snowcrash'

  def show
    @nodes   = Node.in_tree
    @issues  = Issue.where(node_id: Node.issue_library.id).includes(:tags).sort
    @authors = [current_user]

    @methodologies = Node.methodology_library.notes.map{|n| Methodology.new(filename: n.id, content: n.text)}

    @tags = Tag.all
    @tag_names = @tags.map do |tag|
      [tag.name, [tag.display_name, tag.color]]
    end.to_h

    @issues_by_tag  = Hash.new{|h,k| h[k] = [] }
    @count_by_tag   = Hash.new{|h,k| h[k] = 0 }

    @activities = Activity.latest

    @issues.each do |issue|
      if issue.tags.empty?
        @issues_by_tag[:unassigned] << issue
        @count_by_tag[:unassigned] += 1
      else
        issue.tags.each do |tag|
          @issues_by_tag[tag.name] << issue
          @count_by_tag[tag.name] += 1
        end
      end
    end
  end
end
