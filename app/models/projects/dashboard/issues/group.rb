module Projects
  module Dashboard
    module Issues
      Group = Struct.new(:key, :name, :color, :issues, :unassigned, keyword_init: true) do
        def chart_data
          { key: key, name: unassigned? ? 'N/A' : name, color: color, count: count }
        end

        def count
          issues.size
        end

        def unassigned?
          unassigned == true
        end
      end
    end
  end
end
