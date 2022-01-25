class RevisionsController < AuthenticatedController
  include ActivityTracking
  include NodesSidebar
  include ProjectScoped

  before_action :set_variables_from_params, except: [ :trash, :recover ]

  def index
    redirect_to action: :show, id: @record.versions.where(event: 'update').last.try(:id) || 0
  end

  def show
    # Use `reorder`, not `order`, to override Paper Trail's default scope
    @revisions = @record.versions.includes(:item).reorder("created_at DESC")
    @revision  = @revisions.find(params[:id])

    @diffed_revision = DiffedRevision.new(@revision, @record)
  end

  def trash
    # Get all revisions whose event is destroy.
    @revisions = RecoverableRevision.all(project_id: current_project.id)
  end

  def recover
    revision = RecoverableRevision.find(id: params[:id], project_id: current_project.id)
    if revision.recover
      track_recovered(revision.object)
      flash[:info] = "#{revision.type} recovered"
    else
      flash[:error] = "Can't recover #{revision.type}: #{revision.errors.full_messages.join(',')}"
    end

    redirect_to project_trash_path(current_project)
  end

  def sidebar
    render 'revisions/sidebar', layout: false
  end

  private

  def load_issues
    @issues = Issue.where(node_id: current_project.issue_library.id)
    @issue = @issues.find(params[:issue_id])
  end

  def load_list
    @board        = current_project.boards.includes(:lists).find(params[:board_id])
    @list         = @board.lists.includes(:cards).find(params[:list_id])
    @sorted_cards = @list.ordered_cards.select(&:persisted?)
  end

  def load_node
    @node = current_project.nodes.includes(
      :notes, :evidence, evidence: [:issue, { issue: :tags }]
    ).find_by_id(params[:node_id])

    # FIXME: from ProjectScoped
    initialize_nodes_sidebar
  end

  def set_variables_from_params
    if params[:card_id]
      load_list
      @path = sidebar_project_board_list_card_revisions_path
      @record = @list.cards.find(params[:card_id])
    elsif params[:evidence_id]
      load_node
      @path = sidebar_project_node_evidence_revisions_path
      @record = @node.evidence.find(params[:evidence_id])
    elsif params[:issue_id]
      load_issues
      @path = sidebar_project_issue_revisions_path
      @record = @issue
    elsif params[:note_id]
      load_node
      @path = sidebar_project_node_note_revisions_path
      @record = @node.notes.find(params[:note_id])
    else
      raise 'Unable to identify record type'
    end

  rescue ActiveRecord::RecordNotFound
    flash[:error] = 'Record not found'
    redirect_to :back
  end
end
