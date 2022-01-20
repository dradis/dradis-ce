# This controller exposes the REST operations required to manage the Node
# resource.
class NodesController < NestedNodeResourceController
  include DynamicFieldNamesCacher
  include NodesSidebar

  skip_before_action :find_or_initialize_node, only: [ :sort, :create_multiple ]
  before_action :initialize_nodes_sidebar, except: [ :sort, :create_multiple ]
  before_action :set_evidence_default_columns, only: :show

  EXTRA_COLUMNS = ['Title', 'Created', 'Created by', 'Updated'].freeze

  # GET /nodes/<id>
  def show
    @activities       = @node.nested_activities.latest
    @note_columns     = collection_field_names(@node.notes) | EXTRA_COLUMNS
    @evidence_columns = collection_field_names(@node.evidence) | @rtp_default_evidence_fields | EXTRA_COLUMNS
  end

  # GET /nodes/<id>/edit
  def edit
  end

  # POST /nodes
  def create
    @node.label = 'unnamed' unless @node.label.present?
    if @node.save
      track_created(@node)
      flash[:notice] = 'Successfully created node.'
      redirect_to [current_project, @node]
    else
      parent = @node.parent
      if parent && parent.user_node?
        redirect_to [current_project, parent], alert: @node.errors.full_messages.join('; ')
      else
        redirect_to project_path(current_project), alert: @node.errors.full_messages.join('; ')
      end
    end
  end

  def create_multiple
    if params[:nodes][:parent_id].present?
      @parent = current_project.nodes.find(params[:nodes][:parent_id])
    end

    list = params[:nodes][:list].lines.map(&:strip).select(&:present?)

    if list.any?
      Node.transaction do |node|
        list.each do |node_label|
          node = current_project.nodes.create!(
            label: node_label.strip,
            parent: @parent,
            type_id: params[:nodes][:type_id]
          )
          track_created(node)
        end
      end
    end

    flash[:notice] = "Successfully created #{list.length} node#{'s' if list.many?}"
    redirect_to (if @parent
                   project_node_path(current_project, @parent)
                 else
                   project_path(current_project)
                 end)
  end

  # POST /nodes/sort
  def sort
    params[:nodes].each_with_index do |id, index|
      current_project.nodes.update_all({position: index+1}, {id: id})
    end
    head :ok
  end

  # PUT /node/<id>
  def update
    respond_to do |format|
      if @node.update(node_params)
        track_updated(@node)
        format.html { redirect_to project_node_path(current_project, @node), notice: 'Node updated.' }
        format.json { render json: { success: true }.to_json }
        format.js
      else
        format.html do
          flash.now[:alert] = @node.errors.full_messages.join('; ')
          render 'edit'
        end
        format.json { render json: @node.errors.to_json, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /nodes/<id>
  def destroy
    @node.destroy
    track_destroyed(@node)

    parent = @node.parent
    if parent
      redirect_to project_node_path(current_project, parent)
    else
      redirect_to project_path(current_project)
    end
  end

  # Lazy-load the nodes' tree via Ajax calls to this action.
  def tree
    # TODO: Do we want to use :find_or_initialize_node or skip it and :include children?
    @children = @node.children
    respond_to do |format|
      format.js
    end
  end

  private

  def set_evidence_default_columns
    rtp = current_project.report_template_properties
    @rtp_default_evidence_fields = rtp ? rtp.evidence_fields.default.field_names : []

    @default_columns = {}
    @default_columns[:evidence] =
      if @rtp_default_evidence_fields.any?
        @rtp_default_evidence_fields
      else
        ['Title', 'Created', 'Updated']
      end
  end

  def node_params
    params.require(:node).permit(:label, :parent_id, :position, :raw_properties, :type_id)
  end
end
