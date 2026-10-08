module Projects
  module Dashboard
    module Issues
      # Splits a project's issues into Groups for the dashboard "Issues so far"
      # widget. The differences between where the groups come from (`key`,
      # `label`, `values` and `values_for`) live here, so the views and JS only
      # deal with the Groups returned by `#groups`.
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

        def self.available(project)
          [new(project)]
        end

        def self.find(project, key)
          groupings = available(project)
          groupings.find { |grouping| grouping.key == key } || groupings.first
        end

        attr_reader :project

        def initialize(project)
          @project = project
        end

        def key
          'tags'
        end

        def label
          'Tags'
        end

        # Anything that responds to `display_name` and `color`.
        def values
          @values ||= project.tags.to_a
        end

        # Returns one Group per value, followed by an "Unassigned" Group holding the
        # issues that matched no value. An issue matching several values is listed
        # in each of them.
        def groups(issues)
          issues_by_value = values.index_with { [] }
          unassigned = []

          issues.each do |issue|
            matched = values_for(issue)

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

        private

        def values_for(issue)
          values.select { |tag| issue.tags.include?(tag) }
        end
      end
    end
  end
end
