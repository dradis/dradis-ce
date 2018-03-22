class EvidenceController < NestedNodeResourceController

  before_action :find_or_initialize_evidence, except: [ :index, :create_multiple ]
  before_action :initialize_nodes_sidebar, only: [ :edit, :new, :show ]
  skip_before_action :find_or_initialize_node, only: [:create_multiple]

  def show
    @issue      = @evidence.issue
    @activities = @evidence.activities.latest

    load_conflicting_revisions(@evidence)
  end

  def new
    # See ContentFromTemplate concern
    @evidence.content = template_content if params[:template]
  end

  def create
    @evidence.author ||= current_user.email

    respond_to do |format|
      if @evidence.save
        track_created(@evidence)
        format.html {
          redirect_to [@evidence.node, @evidence],
            notice: "Evidence added for node #{@evidence.node.label}."
        }
      else
        format.html {
          initialize_nodes_sidebar
          render "new"
        }
      end
      format.js
    end
  end

  def create_multiple
    # validate Issue
    issue = Issue.find(evidence_params[:issue_id])

    if params[:evidence][:node_ids]
      params[:evidence][:node_ids].reject(&:blank?).each do |node_id|
        node = Node.find(node_id)
        Evidence.create(
          issue_id: issue.id,
          node_id: node.id,
          content: evidence_params[:content]
        )
      end
    end
    if params[:evidence][:node_list]
      if params[:evidence][:node_list_parent_id].present?
        parent = Node.find(params[:evidence][:node_list_parent_id])
      end
      params[:evidence][:node_list].lines.map(&:strip).each do |label|
        node = Node.create_with(type_id: Node::Types::HOST)
          .find_or_create_by(label: label)
        node.update_attributes!(parent: parent) if parent

        Evidence.create(
          issue_id: issue.id,
          node_id: node.id,
          content: evidence_params[:content]
        )
      end
    end
    redirect_to issue_path(evidence_params[:issue_id]), notice: 'Evidence added for selected nodes.'
  end

  def edit
  end

  def update
    respond_to do |format|
      updated_at_before_save = @evidence.updated_at.to_i
      if @evidence.update_attributes(evidence_params)
        track_updated(@evidence)
        check_for_edit_conflicts(@evidence, updated_at_before_save)
        format.html { redirect_to issue_or_node_path, notice: 'Evidence updated.' }
      else
        format.html {
          initialize_nodes_sidebar
          render "edit"
        }
      end
      format.js
    end
  end

  def destroy
    respond_to do |format|
      if @evidence.destroy
        track_destroyed(@evidence)
        format.html {
          redirect_to @node,
            notice: "Successfully deleted evidence for '#{@evidence.issue.title}.'"
        }
        format.js
      else
        format.html {
          redirect_to [@node,@evidence],
            notice: "Error while deleting evidence: #{@evidence.errors}"
        }
        format.js
      end
    end
  end

  def multiple_destroy
    @evidence = @node.evidence.where(id: params[:ids])

    # cache these values
    @count = @evidence.count
    @max_deleted_inline = ::Configuration.max_deleted_inline

    if @count > 0
      @job_logger = Log.new
      job_params = {
        author_email: current_user.email,
        ids: @evidence.map(&:id),
        klass: 'Evidence',
        uid: @job_logger.uid
      }

      if @count > @max_deleted_inline
        @job_logger.write 'Enqueueing multiple delete job to start in the background.'
        job = MultiDestroyJob.perform_later(job_params)
        @job_logger.write "Job id is #{job.job_id}."
      elsif @count > 0
        @job_logger.write 'Performing multiple delete job inline.'
        MultiDestroyJob.perform_now(job_params)
      end
    end
  end

  private

  # Look for the Evidence we are going to be working with based on the :id
  # passed by the user.
  def find_or_initialize_evidence
    if params[:id]
      @evidence = Evidence.includes(:issue, issue: [:tags]).find(params[:id])
    elsif params[:evidence]
      @evidence = Evidence.new(evidence_params) do |e|
        e.node = @node
      end
    else
      @evidence = Evidence.new(node: @node)
    end
  end

  # If the user selects "Add new issue" in the Evidence editor, we create an empty skeleton
  def create_issue
    Issue.create do |issue|
      issue.text = "#[Title]#\nNew issue auto-created for node [#{@node.label}]."
      issue.node = Node.issue_library
      issue.author = current_user.email
    end
  end

  def evidence_params
    params.require(:evidence).permit(:author, :content, :issue_id, :node_id)
  end

  def issue_or_node_path
    if params[:back_to] == 'issue'
      @evidence.issue
    else
      [@node, @evidence]
    end
  end
end
