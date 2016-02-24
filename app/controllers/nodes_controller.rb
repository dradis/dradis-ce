# This controller exposes the REST operations required to manage the Node
# resource.
class NodesController < NestedNodeResourceController

  skip_before_filter :find_or_initialize_node, only: [ :sort ]
  before_filter :initialize_nodes_sidebar, except: [ :sort ]

  # GET /nodes/<id>
  def show
    # FIXME: re-enable Activities
    # @activities = @node.nested_activities.latest
    @activities = []
  end


  # GET /nodes/<id>/edit
  def edit
  end

  # POST /nodes
  def create
    @node.label = 'unnamed' unless @node.label.present?
    if @node.save
      # FIXME: re-enable Activities
      # track_created(@node)
      flash[:notice] = 'Successfully created node.'
      redirect_to @node
    else
      parent = @node.parent
      if parent
        redirect_to parent, alert: @node.errors.full_messages.join('; ')
      else
        redirect_to summary_path, alert: @node.errors.full_messages.join('; ')
      end
    end
  end

  # POST /nodes/sort
  def sort
    params[:nodes].each_with_index do |id, index|
      Node.update_all({position: index+1}, {id: id})
    end
    render nothing: true
  end

  # PUT /node/<id>
  def update
    respond_to do |format|
      if @node.update_attributes(node_params)
        # FIXME: re-enable Activities
        # track_updated(@node)
        format.html { redirect_to node_path(@node), notice: 'Node updated.' }
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
    # FIXME: re-enable Activities
    # track_destroyed(@node)

    parent = @node.parent
    if parent
      redirect_to parent
    else
      redirect_to summary_path
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
  def node_params
    params.require(:node).permit(:label, :parent_id, :position, :raw_properties, :type_id)
  end
end
