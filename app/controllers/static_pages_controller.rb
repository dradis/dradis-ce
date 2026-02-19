class StaticPagesController < AuthenticatedController
  include ProjectScoped

  def issuelib_index; end

  def issuelib_import; end

  def remediationtracker_index
    @tickets = [
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
