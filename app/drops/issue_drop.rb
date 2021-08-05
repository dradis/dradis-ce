class IssueDrop < BaseDrop
  delegate :text, :title, to: :@record

  def affected
    @affected ||= @record.affected.map { |node| NodeDrop.new(node) }
  end

  def fields
    @fields ||= FieldsDrop.new(@record.fields)
  end

  def evidence
    @record.evidence.map { |evidence| EvidenceDrop.new(evidence) }
  end

  def tags
    @tags ||= @record.tags.map { |tag| TagDrop.new(tag) }
  end
end
