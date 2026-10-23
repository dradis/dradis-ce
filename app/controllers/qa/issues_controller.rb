class QA::IssuesController < AuthenticatedController
  include EventPublisher
  include LiquidEnabledResource
  include Mentioned
  include ProjectScoped
  include Publishable

  before_action :set_issues
  before_action :set_issue, only: [:edit, :show, :preview, :update]
  before_action :validate_state, only: [:multiple_update, :update]

  def index
    @all_columns = @default_columns = ['Title']
  end

  def show; end

  def edit
    @form_cancel_path = project_qa_issue_path(current_project, @issue)
    @form_preview_path = preview_project_qa_issue_path(current_project, @issue)
    @tags = current_project.tags
  end

  def update
    if @issue.update(state: @state, updated_at: Time.now)
      publish_event('issue.state_change', @issue.to_event_payload)

      redirect_to *next_issue_or_index_path
    else
      render :show, alert: @issue.errors.full_messages.join('; ')
    end
  end

  def multiple_update
    @issues = current_project.issues.where(id: params[:ids])

    respond_to do |format|
      if @issues.update(state: @state)

        @issues.each do |issue|
          publish_event('issue.state_change', issue.to_event_payload)
        end

        format.html do
          if params[:return_to] == 'qa'
            redirect_to project_qa_issues_path(current_project), notice: 'State updated successfully.'
          else
            redirect_to project_issues_path(current_project), notice: 'State updated successfully.'
          end
        end
      else
        format.html { render :show, alert: @issues.errors.full_messages.join('; ') }
      end
    end
  end

  private

  # Override EventPublisher#event_action_payload to use the semantic action
  # name ('state_change') instead of the RESTful controller actions
  # ('update'/'multiple_update') so the activity feed shows the correct verb.
  def event_action_payload
    action_map = { 'multiple_update' => 'state_change', 'update' => 'state_change' }
    super.merge(action: action_map.fetch(action_name, action_name))
  end

  def issue_params
    params.permit(:state)
  end

  def liquid_resource_assigns
    { 'issue' => IssueDrop.new(@issue) }
  end

  def next_issue_or_index_path
    notice = "State successfully updated for #{@issue.title}."
    next_issue = current_project.issues.ready_for_review.first

    if next_issue
      notice << ' You are now viewing the next issue ready for review.'
      [project_qa_issue_path(current_project, next_issue), { notice: notice }]
    else
      [project_qa_issues_path(current_project), { notice: notice }]
    end
  end

  def set_issue
    @issue = @issues.find(params[:id])
  end

  def set_issues
    @issues = current_project.issues.ready_for_review
  end

  def validate_state
    if Issue.states.keys.include?(params[:state])
      @state = params[:state]
    else
      redirect_to project_qa_issues_path(current_project), alert: 'Something fishy is going on...'
    end
  end
end
