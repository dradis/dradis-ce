# Module to execute revision collapsing on a resource
module RevisionCollapsing
  extend ActiveSupport::Concern

  def collapse_revisions(resource)
    RevisionCollapser.collapse(resource)
  end
end
