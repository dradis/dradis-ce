class TagDrop < BaseDrop
  delegate :color, :display_name, :name, to: :@record

  def tag_issues
    Issue.published.includes(:taggings).where(taggings: {tag: @record}).map do |issue|
      IssueDrop.new(issue)
    end
  end
end
