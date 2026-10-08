class EvidenceDrop < BaseDrop
  include EscapedFields

  delegate :content, :state, :title, to: :@record

  def issue
    IssueDrop.new(@record.issue)
  end
end
