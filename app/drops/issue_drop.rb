class IssueDrop < BaseDrop
  delegate :fields, :text, :title, to: :@record

  def affected
    @affected ||= @record.affected.map { |node| NodeDrop.new(node) }
  end

  def evidence
    @record.evidence.map { |evidence| EvidenceDrop.new(evidence) }
  end

  def tags
    @tags ||= @record.tags.map { |tag| TagDrop.new(tag) }
  end

  def comments
    @comments ||= @record.comments.map { |comment| CommentDrop.new(comment) }
  end
end
