class EvidenceDrop < BaseDrop
  delegate :content, :id, to: :@record
end
