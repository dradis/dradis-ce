class EvidenceController < NestedNodeResourceController

  before_filter :find_or_initialize_evidence, except: [ :index ]
  before_filter :initialize_nodes_sidebar, only: [ :edit, :new, :show ]

  def show
    @issue      = @evidence.issue
    @activities = @evidence.activities.latest
  end

  def new
    @evidence.content = template_content if params[:template]
    # TODO use the textile-editor plugin
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

  def edit
  end

  def update
    respond_to do |format|
      if @evidence.update_attributes(evidence_params)
        track_updated(@evidence)
        format.html { redirect_to [@node, @evidence] }
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
end
