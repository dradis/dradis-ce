class IssueDrop < BaseDrop
  delegate :title, :evidence, :text, to: :@record
end
