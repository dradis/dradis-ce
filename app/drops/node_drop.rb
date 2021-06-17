class NodeDrop < BaseDrop
  delegate :label, to: :@record
end
