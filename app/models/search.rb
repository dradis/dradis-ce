# This is facade for searching multiple models
# so we don't expose more than one instance level variabe
# in controller
class Search
  def initialize(search_term:)
    @term = search_term
  end

  def issues
    Issue.where("text LIKE :term", term: "%#{@term}%")
  end

  def nodes
    Node.where("label LIKE :term", term: "%#{@term}%")
  end

  def notes
    Note.where("text LIKE :term", term: "%#{@term}%")
  end

  def evidences
    Evidence.where("content LIKE :term", term: "%#{@term}%")
  end
end
