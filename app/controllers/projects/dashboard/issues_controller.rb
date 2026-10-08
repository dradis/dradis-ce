class Projects::Dashboard::IssuesController < AuthenticatedController
  include ProjectScoped

  def index
    @issues = current_project.issues.includes(:tags).sort
    @tags = current_project.tags

    @count_by_tag = { unassigned: 0 }
    @issues_by_tag = Hash.new { |h, k| h[k] = [] }

    @tag_names = @tags.map do |tag|
      @count_by_tag[tag.name] = 0
      [tag.name, [tag.display_name, tag.color]]
    end.to_h

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
