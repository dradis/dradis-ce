class EvidenceDrop < BaseDrop
  delegate :content, :fields, :title, to: :@record

  def issue
    IssueDrop.new(@record.issue)
  end
end
