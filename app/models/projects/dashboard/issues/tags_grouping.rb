module Projects
  module Dashboard
    module Issues
      class TagsGrouping
        def groups(issues)
          buckets = @project.tags.to_h do |tag|
            [tag.id, Group.new(key: "tag-#{tag.id}", name: tag.display_name, color: tag.color, issues: [])]
          end
          unassigned = Group.new(key: 'unassigned', name: 'Unassigned', issues: [], unassigned: true)

          issues.each do |issue|
            matches = issue.tags.filter_map { |tag| buckets[tag.id] }
            matches = [unassigned] if matches.empty?
            matches.each { |group| group.issues << issue }
          end

          buckets.values + [unassigned]
        end

        def initialize(project)
          @project = project
        end

        def key
          'tags'
        end

        def label
          'Tags'
        end
      end
    end
  end
end
