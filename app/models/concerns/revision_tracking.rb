module RevisionTracking
  extend ActiveSupport::Concern

  included do
    has_paper_trail
  end

  def has_revision_history?
    versions.where(event: 'update').any?
  end

end
