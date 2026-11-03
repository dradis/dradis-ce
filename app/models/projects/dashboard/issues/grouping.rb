module Projects
  module Dashboard
    module Issues
      # Each strategy exposes a key, a label and groups(issues). Pro adds its
      # report-template strategies here without changing the widget.
      module Grouping
        def self.available(project)
          [TagsGrouping.new(project)]
        end
      end
    end
  end
end
