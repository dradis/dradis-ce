class IssueDrop < BaseDrop
  include EscapedFields

  delegate :author, :text, :title, to: :@record

  def affected
    @affected ||= @record.affected.map { |node| NodeDrop.new(node) }
  end

  def evidence
    @record.evidence.map { |evidence| EvidenceDrop.new(evidence) }
  end

  def tags
    @tags ||= @record.tags.map { |tag| TagDrop.new(tag) }
  end

  ActiveSupport.run_load_hooks(:issue_drop, self)
end
