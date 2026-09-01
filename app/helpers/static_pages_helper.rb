module StaticPagesHelper
  NO_DATA_COLOR = 'var(--secondary-bg)'
  NO_TAG_COLOR  = 'var(--untagged-color)'

  def chart_styles(issue, percent)
    if issue.evidence.any?
      color = issue.tags.first&.color.presence || NO_TAG_COLOR
      "width: #{percent}%; background-color: #{color};"
    else
      "width: 100%; background-color: #{NO_DATA_COLOR};"
    end
  end

  def issues_grouped_by_tag(issues)
    issues_with_tag = issues.includes(:tags).map { |i| [i, i.tags.first] }
    issues_with_tag
      .sort_by { |_, tag| tag&.position || Float::INFINITY }
      .group_by { |_, tag| tag }
      .transform_values { |pairs| pairs.map(&:first) }
  end

  def top_issues_by_evidence_count(project, limit: 3)
    project.issues
           .left_joins(:evidence)
           .includes(:tags, :evidence)
           .group('notes.id')
           .order(Arel.sql('COUNT(evidence.id) DESC'))
           .limit(limit)
  end

  def top_nodes_by_issue_count(project, limit: 3)
    project.nodes.user_nodes
           .joins(:issues)
           .select('nodes.*, COUNT(DISTINCT notes.id) AS issues_count')
           .group('nodes.id')
           .order(Arel.sql('COUNT(DISTINCT notes.id) DESC'))
           .limit(limit)
  end
end
