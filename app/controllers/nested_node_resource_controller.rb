# A controller for pages related to a Node and its notes and evidence.
class NestedNodeResourceController < AuthenticatedController
  include ActivityTracking
  include ContentFromTemplate
  include ProjectScoped

  before_action :find_or_initialize_node

  layout 'nested_node_resource'

  protected

  def find_or_initialize_node
    # FIXME: this is not great design with different branches for different
    # child controllers.
    if params[:controller] == 'nodes'
      if params[:id]
        @node = Node.includes(
          :notes, :evidence, evidence: [:issue, { issue: :tags }]
        ).find(params[:id])
      else
        @node = Node.new(node_params)
      end
    else
      @node = Node.includes(
        :notes, :evidence, evidence: [:issue, { issue: :tags }]
      ).find_by_id(params[:node_id])
    end
  end
end
