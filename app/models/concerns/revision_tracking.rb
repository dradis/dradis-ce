module RevisionTracking
  extend ActiveSupport::Concern

  REVISABLE_EVENTS = %w[auto-save update]

  included do
    has_paper_trail
  end

  def has_revision_history?
    versions.where(event: REVISABLE_EVENTS).any?
  end

end
