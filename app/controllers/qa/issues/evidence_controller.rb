class QA::Issues::EvidenceController < AuthenticatedController
  include DynamicFieldNamesCacher
  include EventPublisher
  include ProjectScoped
  include Publishable

  before_action :set_issue, only: [:edit, :index, :show, :update]
  before_action :set_affected_nodes, only: :index
  before_action :set_columns, only: :index
  before_action :set_evidence, only: [:edit, :show, :update]
  before_action :set_evidence_for_review, only: [:edit, :show]
  before_action :set_node_evidence, only: :index
  before_action :validate_state, only: [:multiple_update, :update]

  def index
    render layout: false
  end

  def show; end

  def edit
    @node = @evidence.node
    @form_preview_path = preview_project_node_evidence_path(current_project, @node, @evidence)
  end

  def update
    if @evidence.update(state: @state, updated_at: Time.now)
      publish_event('evidence.updated', @evidence.to_event_payload)

      redirect_to(*next_evidence_or_index_path)
    else
      render :show, alert: @evidence.errors.full_messages.join('; ')
    end
  end

  def multiple_update
    @issue = current_project.issues.find(params[:issue_id])
    @evidence = Evidence.where(id: params[:ids], issue: @issue)

    respond_to do |format|
      if @evidence.update(state: @state)
        @evidence.each do |evidence|
          publish_event('evidence.updated', evidence.to_event_payload)
        end

        format.html do
          if params[:return_to] == 'qa'
            redirect_to project_qa_issue_path(current_project, @issue, tab: 'evidence-tab'), notice: 'State updated successfully.'
          else
            redirect_to project_issue_path(current_project, @issue, tab: 'evidence-tab'), notice: 'State updated successfully.'
          end
        end
      else
        format.html { render :index, alert: @evidence.errors.full_messages.join('; ') }
      end
    end
  end

  private

  def event_action_payload
    super.merge(action: 'state_change')
  end

  def evidence_params
    params.permit(:state)
  end

  def next_evidence_or_index_path
    notice = 'State successfully updated.'
    next_evidence = @issue.evidence.ready_for_review.first

    if next_evidence
      [project_qa_issue_evidence_path(current_project, @issue, next_evidence), { notice: notice }]
    else
      [project_qa_issue_path(current_project, @issue, tab: 'evidence-tab'), { notice: notice }]
    end
  end

  def set_affected_nodes
    @affected_nodes = Node.joins(:evidence)
                          .select('nodes.id, label, type_id, count(evidence.id) as evidence_count, nodes.updated_at')
                          .where('evidence.issue_id = ? AND evidence.state = ?', @issue.id, Evidence.states[:ready_for_review])
                          .group('nodes.id')
                          .sort_by { |node, _| node.label }
  end

  def set_columns
    default_field_names = ['Label', 'Title'].freeze
    extra_field_names = ['Created', 'Created by', 'Updated'].freeze

    dynamic_fields = dynamic_field_names(@issue.evidence)

    rtp = current_project.report_template_properties
    rtp_default_fields = rtp ? rtp.evidence_fields.default.field_names : []

    @default_columns = rtp_default_fields.presence || default_field_names
    @all_columns = rtp_default_fields | dynamic_fields | extra_field_names
  end

  def set_evidence
    @evidence = @issue.evidence.ready_for_review.find(params[:id])
  end

  def set_evidence_for_review
    @evidence_for_review = @issue.evidence.ready_for_review
  end

  def set_issue
    @issue = current_project.issues.ready_for_review.find(params[:issue_id])
  end

  def set_node_evidence
    @node_evidence = @affected_nodes.index_with { |node| node.evidence.where(issue_id: @issue.id).ready_for_review }
  end

  def validate_state
    if Evidence.states.keys.include?(params[:state])
      @state = params[:state]
    else
      redirect_to project_qa_issue_path(current_project, params[:issue_id], tab: 'evidence-tab'), alert: 'Something fishy is going on...'
    end
  end
end
