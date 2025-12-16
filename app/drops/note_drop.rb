class NoteDrop < BaseDrop
  include EscapedFields

  delegate :text, :title, :updated_at, to: :@record
end
