class NoteDrop < BaseDrop
  delegate :title, :text, to: :@record
end
