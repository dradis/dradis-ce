module Projects
  module IssuesSummaryGrouping
    private

    def build_tags_grouping
      @count_by_tag = Hash.new(0)
      @count_by_tag[:unassigned] = 0
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
    end

    def list_fields
      []
    end
  end
end
