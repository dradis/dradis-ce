class NoteDrop < BaseDrop
  delegate :fields, :text, :title, :updated_at, to: :@record
end
