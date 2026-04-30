class StaticPagesController < AuthenticatedController
  before_action :set_entries, only: [:issuelib_index, :issuelib_import]
  before_action :set_tickets, only: [:remediationtracker_index]

  def issuelib_index; end

  def issuelib_import
    @entries = @entries.select { |e| e[:state] == 'published' }
  end

  def projects_index
    @project = Project.all.first
    render layout: 'hera'
  end

  def remediationtracker_index; end

  private

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
