class TagDrop < Liquid::Drop
  def initialize(tag)
    @tag = tag
  end

  def name
    @tag.name
  end
end
