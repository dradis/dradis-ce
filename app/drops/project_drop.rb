class ProjectDrop < BaseDrop
  delegate :name, to: :@record
end
