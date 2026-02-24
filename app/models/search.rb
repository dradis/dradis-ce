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
        results.page.per(results.count)
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
    @evidence ||=
      begin
        evidence = Evidence.where(node_id: project.nodes.user_nodes.pluck(:id))
        evidence = evidence.where('LOWER(content) LIKE LOWER(:q)', q: "%#{query}%") if query.present?
        evidence.includes(:issue, :node).order(updated_at: :desc)
      end
  end

  def issues
    @issues ||=
      begin
        issues = Issue.where(node: project.issue_library)
        issues = issues.where('LOWER(text) LIKE LOWER(:q)', q: "%#{query}%") if query.present?
        issues.includes(:node, :tags).order(updated_at: :desc)
      end
  end

  def nodes
    @nodes ||=
      begin
        nodes = project.nodes.user_nodes
        nodes = nodes.where('LOWER(label) LIKE LOWER(:q)', q: "%#{query}%") if query.present?
        nodes.order(updated_at: :desc)
      end
  end

  def notes
    @notes ||=
      begin
        notes = Note.where(node_id: project.nodes.user_nodes.pluck(:id))
        notes = notes.where('LOWER(text) LIKE LOWER(:q)', q: "%#{query}%") if query.present?
        notes.includes(:node).order(updated_at: :desc)
      end
  end
end
