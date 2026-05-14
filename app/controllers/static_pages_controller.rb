class StaticPagesController < AuthenticatedController
  before_action :set_entries, only: [:issuelib_index, :issuelib_import]
  before_action :set_gateway_projects, only: [:gateway_index]
  before_action :set_tickets, only: [:remediationtracker_index]

  def gateway_index; end

  def issuelib_index; end

  def issuelib_import
    @entries = @entries.select { |e| e[:state] == 'published' }
  end

  def remediationtracker_index; end

  private

  def set_entries
    @entries = issuelib_entries
  end

  def set_gateway_projects
    @project  = Project.find(1)
    @projects = [
      {
        name:       @project.name,
        team:       'Galactica',
        theme:      'Athena',
        created_at: Date.today - 3.months,
        updated_at: Activity.maximum(:created_at) || Date.today
      }
    ] + gateway_projects
  end

  def set_tickets
    @tickets = tickets
  end

  def gateway_projects
    [
      {
        name:           'Welcome to Dradis',
        team:           'Galactica',
        theme:          'Orion',
        issues_count:   12,
        evidence_count: 34,
        nodes_count:    8,
        created_at:     Date.today - 2.months,
        updated_at:     Date.today - 2.days
      },
      {
        name:           'Dradis Export Owasp',
        team:           'Colonial Fleet',
        theme:          'Athena',
        issues_count:   7,
        evidence_count: 19,
        nodes_count:    5,
        created_at:     Date.today - 3.weeks,
        updated_at:     Date.today - 4.days
      },
      {
        name:           'Redteam',
        team:           'Galactica',
        theme:          'Atlantia',
        issues_count:   21,
        evidence_count: 63,
        nodes_count:    15,
        created_at:     Date.today - 5.months,
        updated_at:     Date.today - 3.weeks
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
end
