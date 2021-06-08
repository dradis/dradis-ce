class IssueDrop < Liquid::Drop
  def initialize(issue)
    @issue = issue
  end

  def title
    @issue.title
  end
end
