class CategoryDrop < BaseDrop
  delegate :name, to: :@record
end
