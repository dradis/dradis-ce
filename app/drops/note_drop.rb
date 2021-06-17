class NoteDrop < BaseDrop
  delegate :id, :text, :title, to: :@record
end
