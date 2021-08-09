class NoteDrop < BaseDrop
  delegate :fields, :text, :title, to: :@record
end
