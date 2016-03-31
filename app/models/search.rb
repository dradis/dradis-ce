# This is facade for searching multiple models
# so we don't expose more than one instance level variabe
# in controller
class Search
  attr_reader :term, :scope, :page

  def initialize(search_term:, scope: "all", page: 1)
    @term  = search_term
    @scope = scope
    @page  = page
  end

  # return results based on params
  # if search term is empty return empty array
  def results
    return [] if term.blank?
    #default kaminari per page is 30, as we are using here
    results_array = send(scope.to_sym).to_a
    Kaminari.paginate_array(results_array).page(page)
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
    Issue.search(term: term)
  end

  def nodes
    Node.search(term: term)
  end

  def notes
    Note.search(term: term)
  end

  def evidences
    Evidence.search(term: term)
  end
end
