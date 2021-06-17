class TagDrop < BaseDrop
  delegate :display_name, :id, :name, to: :@record
end
