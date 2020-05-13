module RevisionTracking
  extend ActiveSupport::Concern

  REVISABLE_EVENTS = {
    autosave: 'auto-save',
    update: 'update'
  }.freeze

  included do
    has_paper_trail
  end

  def revisable_versions
    versions.where(event: REVISABLE_EVENTS.values)
  end

  def has_revision_history?
    revisable_versions.any?
  end
end
