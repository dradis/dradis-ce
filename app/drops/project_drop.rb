class ProjectDrop < BaseDrop
  delegate :id, :name, to: :@record
end
