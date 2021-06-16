class IssueDrop < Liquid::Drop
  def initialize(issue)
    @issue = issue
  end

  def title
    @issue.title
  end

  def evidence
    @issue.evidence
  end

  def text
    @issue.text
  end
end
