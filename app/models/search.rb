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
    # Default Kaminari per page is 25, as we are using here
    results = send(scope)
    case results
    when ActiveRecord::Relation
      if page
        results.page(page)
      else
        results
      end
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
    @evidence_count ||= evidence.count
  end

  private

  def all
    @all ||= nodes + notes + evidence + issues
  end

  def evidence
    @evidence ||= begin
      Evidence.where(
        'node_id IN (:nodes) AND LOWER(content) LIKE LOWER(:q)',
        nodes: project.nodes.user_nodes.pluck(:id),
        q: "%#{query}%"
      )
        .includes(:issue, :node)
        .order(updated_at: :desc)
    end
  end

  def issues
    @issues ||=
      begin
        issues = Issue.where(node: project.issue_library)
        issues = issues.where("LOWER(text) LIKE LOWER(:q)", q: "%#{query}%") if query
        issues.order(updated_at: :desc)
      end
  end

  def nodes
    @nodes ||= project.nodes.user_nodes
      .where("LOWER(label) LIKE LOWER(:q)", q: "%#{query}%")
      .order(updated_at: :desc)
  end

  def notes
    @notes ||= begin
      Note.where(
        "node_id IN (:nodes) AND LOWER(text) LIKE LOWER(:q)",
        nodes: project.nodes.user_nodes.pluck(:id),
        q: "%#{query}%"
      )
        .includes(:node)
        .order(updated_at: :desc)
    end
  end
end
