class Issues::EvidenceController < AuthenticatedController
  include ContentFromTemplate
  include DynamicFieldNamesCacher
  include MultipleDestroy
  include ProjectScoped

  before_action :set_issues, only: [:index, :new]
  before_action :set_affected_nodes, only: :index
  before_action :set_columns, only: :index

  def index
    render layout: false
  end

  def new
    @nodes_for_add_evidence = current_project.nodes.user_nodes.order(:label)

    @template_content = template_content if params[:template]
  end

  private

  def set_columns
    default_field_names = ['Label', 'Title'].freeze
    extra_field_names = ['Created', 'Created by', 'Updated'].freeze

    dynamic_fields = dynamic_field_names(@issue.evidence)

    rtp = current_project.report_template_properties
    rtp_default_fields = rtp ? rtp.issue_fields.default.field_names : []

    @default_columns = rtp_default_fields.presence || default_field_names
    @all_columns = rtp_default_fields | dynamic_fields | extra_field_names
  end

  def set_affected_nodes
    @affected_nodes = Node.joins(:evidence)
                          .select('nodes.id, label, type_id, count(evidence.id) as evidence_count, nodes.updated_at')
                          .where('evidence.issue_id = ?', @issue.id)
                          .group('nodes.id')
                          .sort_by { |node, _| node.label }
  end

  def set_auto_save_key
    @auto_save_key =  if params[:template]
      "project-#{current_project.id}-issue-#{params[:issue_id]}-evidence-#{params[:template]}"
    else
      "project-#{current_project.id}-issue-#{params[:issue_id]}-evidence"
    end
  end

  def set_issues
    @issues = current_project.issues.order(:text)
    @issue = @issues.find(params[:issue_id])
  end
end
