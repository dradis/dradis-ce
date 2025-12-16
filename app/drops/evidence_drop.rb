class EvidenceDrop < BaseDrop
  include EscapedFields

  delegate :content, :title, to: :@record

  def issue
    IssueDrop.new(@record.issue)
  end
end
