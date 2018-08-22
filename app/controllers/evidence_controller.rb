class EvidenceController < NestedNodeResourceController
  include ConflictResolver
  include MultipleDestroy
  include NodesSidebar

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
          redirect_to [current_project, @evidence.node, @evidence],
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
    issue = current_project.issues.find(evidence_params[:issue_id])

    if params[:evidence][:node_ids]
      params[:evidence][:node_ids].reject(&:blank?).each do |node_id|
        node = current_project.nodes.find(node_id)
        Evidence.create(
          issue_id: issue.id,
          node_id: node.id,
          content: evidence_params[:content]
        )
      end
    end
    if params[:evidence][:node_list]
      if params[:evidence][:node_list_parent_id].present?
        parent = current_project.nodes.find(params[:evidence][:node_list_parent_id])
      end
      params[:evidence][:node_list].lines.map(&:strip).each do |label|
        node = current_project.nodes.create_with(type_id: Node::Types::HOST)
          .find_or_create_by(label: label)
        node.update_attributes!(parent: parent) if parent

        Evidence.create(
          issue_id: issue.id,
          node_id: node.id,
          content: evidence_params[:content]
        )
      end
    end
    redirect_to project_issue_path(current_project, evidence_params[:issue_id]), notice: 'Evidence added for selected nodes.'
  end

  def edit
  end

  def update
    respond_to do |format|
      updated_at_before_save = @evidence.updated_at.to_i
      if @evidence.update_attributes(evidence_params)
        track_updated(@evidence)
        check_for_edit_conflicts(@evidence, updated_at_before_save)
        format.html do
          path = if params[:back_to] == 'issue'
                   [current_project, @evidence.issue]
                 else
                   [current_project, @node, @evidence]
                 end
          redirect_to path, notice: 'Evidence updated.'
        end

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
          redirect_to [current_project, @node],
            notice: "Successfully deleted evidence for '#{@evidence.issue.title}.'"
        }
        format.js
      else
        format.html {
          redirect_to [current_project, @node, @evidence],
            notice: "Error while deleting evidence: #{@evidence.errors}"
        }
        format.js
      end
    end
  end

  private

  # Look for the Evidence we are going to be working with based on the :id
  # passed by the user.
  def find_or_initialize_evidence
    if params[:id]
      @evidence = @node.evidence.includes(:issue, issue: [:tags]).find(params[:id])
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
      issue.node = current_project.issue_library
      issue.author = current_user.email
    end
  end

  def evidence_params
    params.require(:evidence).permit(:author, :content, :issue_id, :node_id)
  end
end
