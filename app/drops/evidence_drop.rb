class EvidenceDrop < BaseDrop
  delegate :content, :title, to: :@record

  def fields
    @fields ||= FieldsDrop.new(@record.fields)
  end

  def issue
    IssueDrop.new(@record.issue)
  end
end
