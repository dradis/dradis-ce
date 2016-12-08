class RevisionPresenter < BasePresenter
  presents :revision

  delegate :whodunnit, to: :revision

  def created_at_ago
    h.local_time_ago(revision.created_at)
  end

  def action
    if revision.event == 'create'
      revision.previous.present? ? 'Recovered' : 'Created'
    else # event can only be 'update' or 'destroy'
      revision.event.sub(/e?\z/, 'ed').capitalize
    end
  end

end
