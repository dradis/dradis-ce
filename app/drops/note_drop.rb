class NoteDrop < BaseDrop
  delegate :text, :title, to: :@record
end
