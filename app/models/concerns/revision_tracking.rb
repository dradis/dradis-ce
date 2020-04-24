module RevisionTracking
  extend ActiveSupport::Concern

  REVISABLE_EVENTS = %w[auto-save update]

  included do
    has_paper_trail
  end

  def revisable_versions
    versions.where(event: REVISABLE_EVENTS)
  end

  def has_revision_history?
    revisable_versions.any?
  end
end
