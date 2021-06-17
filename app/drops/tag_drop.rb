class TagDrop < BaseDrop
  delegate :id, :name, to: :@record
end
