# This is facade for searching multiple models
# so we don't expose more than one instance level variabe
# in controller
class Search
  def initialize(search_term:, scope: "all")
    @term = search_term
    @scope =  scope.blank? ? "all" : scope
  end

  # return results based on params
  # if search term is empty return empty array
  def results
    return [] if @term.blank?
    send(@scope.to_sym)
  end

  def total_count
    nodes_count + notes_count + issues_count +
      evidences_count
  end

  def nodes_count
    nodes.size
  end

  def notes_count
    notes.size
  end

  def issues_count
    issues.size
  end

  def evidences_count
    evidences.size
  end

  private

  def all
    nodes + notes + evidences + issues
  end

  def issues
    Issue.search(term: @term)
  end

  def nodes
    Node.search(term: @term)
  end

  def notes
    Note.search(term: @term)
  end

  def evidences
    Evidence.search(term: @term)
  end
end
