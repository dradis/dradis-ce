module Projects
  module Dashboard
    module Issues
      # Splits a project's issues into Groups for the dashboard "Issues so far"
      # widget, one per value. A value is a Tag, or anything that quacks like one
      # (`display_name`, `color` and `tagged?(issue)`). The views and JS only deal
      # with the Groups returned by `#groups`.
      class Grouping
        # One bucket of issues, e.g. a tag or a list field value. This is all the
        # views and the chart JS know about.
        Group = Struct.new(:name, :color, :issues, :unassigned, keyword_init: true) do
          def count
            issues.size
          end

          def unassigned?
            unassigned.present?
          end

          def chart_data
            { name: name, color: color, count: count, unassigned: unassigned? }
          end
        end

        # Report template properties (and so ListField) only exist in Pro. In CE
        # this is just the tags grouping.
        def self.available(project)
          lists = (project.report_template_properties&.issue_fields&.lists || []).map do |field|
            ListField.new(project, field)
          end

          [new(key: 'tags', label: 'Tags', values: project.tags.to_a)] +
            lists.map { |list| new(key: list.key, label: list.label, values: list.values) }
        end

        attr_reader :key, :label, :values

        def initialize(key:, label:, values:)
          @key = key
          @label = label
          @values = values
        end

        # Returns one Group per value, followed by an "Unassigned" Group holding the
        # issues that matched no value. An issue matching several values is listed
        # in each of them.
        def groups(issues)
          issues_by_value = values.index_with { [] }
          unassigned = []

          issues.each do |issue|
            matched = values.select { |value| value.tagged?(issue) }

            if matched.empty?
              unassigned << issue
            else
              matched.each { |value| issues_by_value[value] << issue }
            end
          end

          groups = issues_by_value.map do |value, value_issues|
            Group.new(name: value.display_name, color: value.color, issues: value_issues)
          end

          groups << Group.new(name: 'Unassigned', issues: unassigned, unassigned: true)
        end
      end
    end
  end
end
