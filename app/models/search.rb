# This is facade for searching multiple models
# so we don't expose more than one instance level variabe
# in controller
class Search
  def initialize(search_term:, scope:)
    @term = search_term
    @scope = scope
  end

  def results
    if !@scope.blank?
      send(@scope.to_sym)
    else
      all
    end
  end

  def issues
    Issue.where("text LIKE :term", term: "%#{@term}%")
      .select("id, text as value")
  end

  def nodes
    Node.where("label LIKE :term", term: "%#{@term}%")
      .select("id, label as value")
  end

  def notes
    Note.where("text LIKE :term", term: "%#{@term}%")
      .select("id, text as value")
  end

  def evidences
    Evidence.where("content LIKE :term", term: "%#{@term}%")
      .select("id, content as value")
  end

  def all
    nodes + notes + evidences + issues
  end
end
