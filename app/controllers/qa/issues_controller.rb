class QA::IssuesController < AuthenticatedController
  include LiquidEnabledResource
  include ProjectScoped

  before_action :set_issues
  before_action :set_issue, only: [:edit, :show]
  before_action :store_location, only: [:index, :show]
  before_action :validate_state, only: [:bulk_update, :update]

  def index
    @issues = current_project.issues.ready_for_review
    @all_columns = @default_columns = ['Title']
  end

  def show; end

  def edit
    @form_cancel_path = project_qa_issue_path(current_project, @issue)
    @tags = current_project.tags
  end

  def bulk_update
    @issues = current_project.issues.where(id: params[:ids])

    respond_to do |format|
      if @issues.update_all(state: @state, updated_at: Time.now)
        format.html do
          redirect_to_target_or_default project_qa_issues_path(current_project), notice: 'State updated successfully.'
        end
        format.json { head :ok }
      else
        format.html { render :show, alert: @issue.errors.full_messages.join('; ') }
        format.json { head :not_found }
      end
    end
  end

  def update
    issue = current_project.issues.find(params[:id])

    if issue.update(state: @state, updated_at: Time.now)
      redirect_to project_qa_issues_path(current_project), notice: 'State updated successfully.'
    else
      format.html { render :show, alert: @issue.errors.full_messages.join('; ') }
    end
  end

  private

  def issue_params
    params.permit(:state)
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
