# This is facade for searching multiple models
# so we don't expose more than one instance level variabe
# in controller
class Search
  def initialize(search_term:, scope: "all")
    @term = search_term
    @scope =  scope.blank? ? "all" : scope
  end

  def results
    send(@scope.to_sym)
  end

  def total_count
    @_total_count ||= nodes_count + notes_count + issues_count +
      evidences_count
  end

  def nodes_count
    @_issues_count ||= nodes.size
  end

  def notes_count
    @_notes_count ||= notes.size
  end

  def issues_count
    @_issues_count ||= issues.size
  end

  def evidences_count
    @_issues_count ||= evidences.size
  end

  private

  def all
    nodes + notes + evidences + issues
  end

  def issues
    Issue.where("text LIKE :term", term: "%#{@term}%")
      .select(:id, :text)
  end

  def nodes
    Node.where("label LIKE :term", term: "%#{@term}%")
      .select(:id, :label)
  end

  def notes
    Note.where("text LIKE :term", term: "%#{@term}%")
      .select(:id, :text, :category_id)
  end

  def evidences
    Evidence.where("content LIKE :term", term: "%#{@term}%")
      .select("id, content as value")
  end
end
