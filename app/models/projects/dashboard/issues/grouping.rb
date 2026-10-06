module Projects
  module Dashboard
    module Issues
      # A way of splitting a project's issues into groups. Subclasses describe where
      # the groups come from (`values`) and how an issue ends up in one
      # (`matches?`). Everything downstream (views, JS) only deals with the Groups
      # returned by `#groups`, so it never needs to know about the origin.
      #
      # A value is anything that responds to `display_name` and `color`.
      class Grouping
        def self.available(project)
          [TagsGrouping.new(project)]
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
          raise NotImplementedError
        end

        def label
          raise NotImplementedError
        end

        def values
          raise NotImplementedError
        end

        def matches?(_value, _issue)
          raise NotImplementedError
        end

        # Returns one Group per value, followed by an "Unassigned" Group holding the
        # issues that matched no value. An issue matching several values is listed
        # in each of them.
        def groups(issues)
          issues_by_value = values.index_with { [] }
          unassigned = []

          issues.each do |issue|
            matched = values.select { |value| matches?(value, issue) }

            if matched.empty?
              unassigned << issue
            else
              matched.each { |value| issues_by_value[value] << issue }
            end
          end

          issues_by_value.map { |value, value_issues|
            Group.new(name: value.display_name, color: value.color, issues: value_issues)
          } << Group.new(name: 'Unassigned', issues: unassigned, unassigned: true)
        end
      end
    end
  end
end
