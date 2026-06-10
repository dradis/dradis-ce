class StaticPagesController < AuthenticatedController
  before_action :set_bi_stats, only: [:bi_index]
  before_action :set_bi_issues_data, only: [:bi_insights_issues, :bi_insights_top_issues]
  before_action :set_entries, only: [:issuelib_index, :issuelib_import]
  before_action :set_tickets, only: [:remediationtracker_index]

  def bi_index; end

  def bi_insights_issues
    render partial: 'static_pages/bi_index/issue_stats'
  end

  def bi_insights_top_issues
    render partial: 'static_pages/bi_index/top_issues'
  end

  def issuelib_index; end

  def issuelib_import
    @entries = @entries.select { |e| e[:state] == 'published' }
  end

  def projects_index
    @project = Project.find(1)
    render layout: 'hera'
  end

  def remediationtracker_index; end

  private

  def set_bi_stats
    set_bi_issues_data

    current_year_start = Time.current.beginning_of_year
    last_year_start    = 1.year.ago.beginning_of_year
    last_year_end      = 1.year.ago

    current_users_count = User.where(created_at: current_year_start..Time.current).count
    last_users_count    = User.where(created_at: last_year_start..last_year_end).count

    @bi_projects     = { current_year_count: 1, last_year_count: 1, yoy_delta: 0 }
    @bi_contributors = {
      current_year_count: current_users_count,
      last_year_count:    last_users_count,
      yoy_delta:          yoy_delta(current_users_count, last_users_count)
    }
  end

  def set_bi_issues_data
    current_year_start = Time.current.beginning_of_year
    last_year_start    = 1.year.ago.beginning_of_year
    last_year_end      = 1.year.ago

    issuelib_ids = Node.where(type_id: Node::Types::ISSUELIB).pluck(:id)
    issues       = Issue.where(node_id: issuelib_ids)

    @bi_tags      = Tag.joins(:taggings).where(taggings: { taggable_type: Issue.base_class.name, taggable_id: issues.select(:id) }).distinct
    @selected_tag = params[:tag].presence
    @selected_tag = nil unless @bi_tags.exists?(name: @selected_tag)

    filtered_issues = @selected_tag ? issues.joins(:tags).where(tags: { name: @selected_tag }) : issues

    current_issues_count = filtered_issues.where(created_at: current_year_start..Time.current).count
    last_issues_count    = filtered_issues.where(created_at: last_year_start..last_year_end).count

    @bi_issues = {
      current_year_count: current_issues_count,
      last_year_count:    last_issues_count,
      yoy_delta:          yoy_delta(current_issues_count, last_issues_count)
    }
    @bi_top_issues = filtered_issues.where(created_at: current_year_start..Time.current)
      .includes(:tags)
      .group_by(&:title)
      .map { |title, group| { title: title, count: group.size, issue: group.first } }
      .sort_by { |stats| -stats[:count] }
      .first(10)
  end

  def yoy_delta(current, previous)
    if previous.zero?
      current > 0 ? 100 : 0
    else
      ((current - previous).to_f / previous * 100).round
    end
  end

  def set_entries
    @entries = issuelib_entries
  end

  def set_tickets
    @tickets = tickets
  end

  def tickets
    [
      {
        title:    'SQL Injection in Login Form',
        category: 'Security',
        state:    'Open',
        assignee: 'James T. Kirk',
        due_at:   Date.today - 1.week,
        overdue:  true
      },
      {
        title:    'Outdated SSL Certificate',
        category: 'Infrastructure',
        state:    'In Progress',
        assignee: 'Nyota Uhura',
        due_at:   Date.today,
        overdue:  true
      },
      {
        title:    'Cross-Site Scripting in Search Bar',
        category: 'Application',
        state:    'On Hold',
        assignee: 'Montgomery Scott',
        due_at:   Date.today + 1.week,
        overdue:  false
      },
      {
        title:    'Missing HTTP Security Headers',
        category: 'Compliance',
        state:    'Closed',
        assignee: nil,
        due_at:   Date.today + 1.month,
        overdue:  false
      }
    ]
  end

  def issuelib_entries
    [
      {
        title:      'Auto-complete in password field',
        state:      'published',
        created_at: Date.today - 3.months,
        updated_at: Date.today - 1.week
      },
      {
        title:      'DOM-based cross-site scripting (XSS)',
        state:      'published',
        created_at: Date.today - 6.weeks,
        updated_at: Date.today - 3.days
      },
      {
        title:      'Insufficient cross-site request forgery (CSRF) protection',
        state:      'published',
        created_at: Date.today - 2.months,
        updated_at: Date.today - 2.weeks
      },
      {
        title:      'Reflected cross-site scripting (XSS)',
        state:      'published',
        created_at: Date.today - 5.weeks,
        updated_at: Date.today - 4.days
      },
      {
        title:      'Insecure Direct Object Reference (IDOR)',
        state:      'ready_for_review',
        created_at: Date.today - 2.weeks,
        updated_at: Date.today - 1.day
      },
      {
        title:      'Server-Side Request Forgery (SSRF)',
        state:      'draft',
        created_at: Date.today - 3.days,
        updated_at: Date.today
      }
    ]
  end
end
