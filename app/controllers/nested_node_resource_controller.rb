# A controller for pages related to a Node and its notes and evidence.
class NestedNodeResourceController < ProjectScopedController

  before_filter :find_or_initialize_node

  layout 'nested_node_resource'
  protected

  # Used to prefill a form from a NoteTemplate.
  #
  # When the user wants to create an Evidence or Note from a pre-existing
  # template, then the parameter "template" in the query string will equal the
  # name of the template they want to use. Use @template_content@ to get the
  # NoteTemplate from the query params.
  def template_content
    NoteTemplate.find(params[:template]).content
  rescue Exception => e
    # Fail gracefully if the template can't be found; don't make the
    # whole action fail e.g. because of a mistake in the query string.
    if e.message == "Not found!"
      return ""
    else
      raise e
    end
  end

  def find_or_initialize_node
    # FIXME: this is not great design with different branches for different
    # child controllers.
    if params[:controller] == "nodes"
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

  def node_params
    raise 'boom!'
    params[:node] || ActiveSupport::JSON.decode(params[:data])
  end

end
