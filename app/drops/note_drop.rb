class NoteDrop < Liquid::Drop
  delegate :title, :text, to: :@record
end
