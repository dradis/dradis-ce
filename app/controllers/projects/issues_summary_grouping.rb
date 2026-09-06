module Projects
  module IssuesSummaryGrouping
    private

    def build_grouping(_grouping)
      @grouping = 'tags'
      build_tags_grouping
    end

    def build_tags_grouping
      @count_by_tag = Hash.new(0)
      @issues_by_tag = Hash.new { |h, k| h[k] = [] }

      @tag_names = @tags.map do |tag|
        @count_by_tag[tag.name] = 0
        [tag.name, [tag.display_name, tag.color]]
      end.to_h
      @count_by_tag[:unassigned] = 0

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
        grouping: 'tags',
        tags: @tag_names.to_json,
        issues_count: @count_by_tag.to_json
      }
    end

    def list_fields
      []
    end
  end
end
