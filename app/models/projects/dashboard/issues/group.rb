module Projects
  module Dashboard
    module Issues
      # One bucket of issues in the dashboard "Issues so far" widget (e.g. a tag or
      # a list field value). Groups from any source share this interface.
      class Group
        attr_reader :color, :issues, :name

        def initialize(name:, issues:, color: nil, unassigned: false)
          @name = name
          @issues = issues
          @color = color
          @unassigned = unassigned
        end

        def count
          issues.size
        end

        def unassigned?
          @unassigned
        end

        def chart_data
          { name: name, color: color, count: count, unassigned: unassigned? }
        end
      end
    end
  end
end
