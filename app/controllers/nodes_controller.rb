# This controller exposes the REST operations required to manage the Node
# resource.
class NodesController < NestedNodeResourceController

  skip_before_filter :find_or_initialize_node, only: [ :sort, :multiple ]
  before_filter :initialize_nodes_sidebar, except: [ :sort, :multiple ]

  # GET /nodes/<id>
  def show
    @activities = @node.nested_activities.latest
  end


  # GET /nodes/<id>/edit
  def edit
  end

  # POST /nodes
  def create
    @node.label = 'unnamed' unless @node.label.present?
    @node.save!
    track_created(@node)
    flash[:notice] = 'Successfully created node.'
    redirect_to @node
  end

  def multiple
    if params[:nodes][:parent_id].present?
      @parent = Node.find(params[:nodes][:parent_id])
    end

    list = params[:nodes][:list].split(/\n/).map(&:strip).select(&:present?)

    if list.any?
      Node.transaction do |node|
        list.each do |node_label|
          node = Node.create!(label: node_label.strip, parent: @parent)
          track_created(node)
        end
      end
    end

    flash[:notice] = "Successfully created #{list.length} node#{'s' if list.many?}"
    redirect_to @parent ? node_path(@parent) : summary_path
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
        track_updated(@node)
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
    track_destroyed(@node)

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
