class TagDrop < BaseDrop
  delegate :color, :display_name, :name, to: :@record

  def initialize(record, scope = :all)
    super(record)
    @scope = scope
  end

  def tag_issues
    scoped_issues.includes(:taggings).where(taggings: { tag: @record }).map do |issue|
      IssueDrop.new(issue, @scope)
    end
  end

  private

  def scoped_issues
    Issue.public_send(@scope)
  end
end
