# This is facade for searching multiple models
# so we don't expose more than one instance level variable
# in controller
class Search
  attr_reader :page, :project, :query, :scope

  def initialize(query:, scope: :all, page: 1, project:)
    @query   = query
    @scope   = scope
    @page    = page
    @project = project
  end

  # Return results based on params.
  # If search term is empty return empty array
  def results
    return [] if query.blank?
    # Default Kaminari per page is 25, as we are using here
    results = send(scope)
    case results
    when ActiveRecord::Relation
      results.page(page)
    else
      Kaminari.paginate_array(results).page(page)
    end
  end

  def total_count
    @total_count ||= nodes_count + notes_count + issues_count + evidence_count
  end

  def nodes_count
    @nodes_count ||= nodes.count
  end

  def notes_count
    @notes_count ||= notes.count
  end

  def issues_count
    @issues_count ||= issues.count
  end

  def evidence_count
    @evidence_count ||= evidence.size
  end

  private

  def all
    @all ||= nodes + notes + evidence + issues
  end

  def issues
    @issues ||= Issue.where(
      "node_id = :node AND LOWER(text) LIKE LOWER(:q)",
      node: project.issue_library,
      q: "%#{query}%"
    ).order(updated_at: :desc)
  end

  def nodes
    @nodes ||= project.nodes.user_nodes
      .where("LOWER(label) LIKE LOWER(:q)", q: "%#{query}%")
      .order(updated_at: :desc)
  end

  def notes
    @notes ||= begin
      system_nodes = [project.issue_library.id, project.methodology_library.id]

      Note.where(
        "node_id NOT IN (:nodes) AND LOWER(text) LIKE LOWER(:q)",
        nodes: system_nodes,
        q: "%#{query}%"
      )
        .includes(:node)
        .order(updated_at: :desc)
    end
  end

  def evidence
    @evidence ||= Evidence.where("LOWER(content) LIKE LOWER(:q)", q: "%#{query}%")
      .includes(:issue, :node)
      .order(updated_at: :desc)
  end
end
