module RevisionTracking
  extend ActiveSupport::Concern

  REVISABLE_EVENTS = [
    Activity::VALID_ACTIONS[:autosave],
    Activity::VALID_ACTIONS[:update]
  ].freeze

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
