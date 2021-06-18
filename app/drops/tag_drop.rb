class TagDrop < BaseDrop
  delegate :color, :display_name, :name, to: :@record

  def tag_issues
    Issue.includes(:taggings).where(taggings: {tag: @record}).map { |issue| IssueDrop.new(issue) }
  end
end
