class TagDrop < Liquid::Drop
  delegate :name, to: :@record
end
