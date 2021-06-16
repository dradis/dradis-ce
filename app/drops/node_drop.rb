class NodeDrop < Liquid::Drop
  def initialize(node)
    @node = node
  end

  def label
    @node.label
  end
end
