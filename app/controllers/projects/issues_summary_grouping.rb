module Projects
  module IssuesSummaryGrouping
    private

    def build_grouping(grouping)
      valid_groupings = ['tags'] + @list_fields.map { |field| "list:#{field.name}" }
      @grouping = valid_groupings.include?(grouping) ? grouping : 'tags'

      items =
        if @grouping.start_with?('list:')
          field_name = @grouping.delete_prefix('list:')
          @list_field = @list_fields.find { |f| f.name == field_name }
          (@list_field&.values || []).map { |v| ListFieldValue.new(v, field_name: field_name, project: current_project) }
        else
          @grouping = 'tags'
          @tags
        end

      @entries = items.to_h { |item| [item.name, [item.display_name, item.color]] }
      @count_by_value, @issues_by_value = build_value_grouping(items)

      @chart_data = {
        grouping: @grouping,
        tags: @entries.to_json,
        issues_count: @count_by_value.to_json
      }
    end

    def build_value_grouping(items)
      count_by_value = Hash.new(0)
      items.each { |item| count_by_value[item.name] = 0 }
      count_by_value[:unassigned] = 0
      issues_by_value = Hash.new { |h, k| h[k] = [] }

      @issues.each do |issue|
        matched = items.select { |item| item.matches?(issue) }

        if matched.empty?
          issues_by_value[:unassigned] << issue
          count_by_value[:unassigned] += 1
        else
          matched.each do |item|
            issues_by_value[item.name] << issue
            count_by_value[item.name] += 1
          end
        end
      end

      [count_by_value, issues_by_value]
    end

    def list_fields
      current_project.report_template_properties
        &.issue_fields
        &.select { |f| f.type == :list } || []
    end
  end
end
