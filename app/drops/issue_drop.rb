class IssueDrop < BaseDrop
  delegate \
    :evidence,
    :evidence_by_node,
    :text,
    :title,
    to: :@record

  def affected
    @affected ||= @record.affected.map { |node| NodeDrop.new(node) }
  end

  def tags
    @tags ||= @record.tags.map { |tag| TagDrop.new(tag) }
  end
end
