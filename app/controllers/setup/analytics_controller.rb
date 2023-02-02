module Setup
  class AnalyticsController < BaseController

    def save_event
      case params[:name]
      when 'report.exported'
        properties = params[:properties]
        properties[:issue_count] = Project.find(1).issues.count
        properties[:evidence_count] = Project.find(1).evidence.count
        properties[:node_count] = Project.find(1).nodes.count
      end
      ahoy.track params[:name], params[:properties]
    end

    private

    def ensure_pristine
      true
    end
  end
end
