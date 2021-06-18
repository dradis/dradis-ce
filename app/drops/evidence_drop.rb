class EvidenceDrop < BaseDrop
  delegate :content, to: :@record
end
