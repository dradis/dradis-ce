module Projects
  module Dashboard
    module Issues
      class TagsGrouping < Grouping
        def key
          'tags'
        end

        def label
          'Tags'
        end

        def values
          @values ||= project.tags.to_a
        end

        def matches?(tag, issue)
          issue.tags.include?(tag)
        end
      end
    end
  end
end
