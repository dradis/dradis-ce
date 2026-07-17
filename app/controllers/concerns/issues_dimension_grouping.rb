module IssuesDimensionGrouping
  private

  def build_all_tags_grouping
    @count_by_tag = Hash.new(0)
    @issues_by_tag = Hash.new { |h, k| h[k] = [] }
    @tag_names = @tags.map do |tag|
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

    @chart_data = {
      dimension: 'tags',
      tags: @tag_names.to_json,
      issues_count: @count_by_tag.to_json
    }
  end
end
