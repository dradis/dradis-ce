class Issues::EvidenceController < AuthenticatedController
  include ContentFromTemplate
  include DynamicFieldNamesCacher
  include MultipleDestroy
  include ProjectScoped

  before_action :set_default_columns, only: :index
  before_action :set_issues, only: [:index, :new]
  before_action :set_affected_nodes, only: :index

  EXTRA_COLUMNS = ['Created by', 'Created', 'Updated'].freeze
  SKIP_COLUMNS = ['Title', 'Label'].freeze

  def index
    @evidence_columns =
      ['Affected'] |
      (collection_field_names(@issue.evidence) - SKIP_COLUMNS) |
      @rtp_default_fields |
      EXTRA_COLUMNS

    render layout: false
  end

  def new
    @nodes_for_add_evidence = current_project.nodes.user_nodes.order(:label)

    @template_content = template_content if params[:template]
  end

  private

  def all_evidence_columns
    @issue.evidence
          .map { |evidence| evidence.fields.keys }
          .flatten
          .uniq - ['Title', 'Label']
  end

  def set_default_columns
    rtp = current_project.report_template_properties
    @rtp_default_fields = rtp ? rtp.evidence_fields.default.field_names : []

    @default_columns =
      if @rtp_default_fields.any?
        @rtp_default_fields
      else
        ['Node', 'Created by']
      end
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
    @issues = current_project.issues
    @issue = @issues.find(params[:issue_id])
  end
end
