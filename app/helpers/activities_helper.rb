module ActivitiesHelper
  def users_for_select
    current_project.activities.map(&:user).uniq.union(current_project.authors.enabled)
  end
end
