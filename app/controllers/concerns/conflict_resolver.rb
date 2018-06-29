module ConflictResolver
  extend ActiveSupport::Concern

  protected
  def check_for_edit_conflicts(record, updated_at_before_save)
    name = record.model_name.name.downcase
    if params[name][:original_updated_at].to_i < updated_at_before_save
      # Even if there have been edit conflicts, the save will still be
      # successful, which means we're going to *redirect* to another action
      # (#show), rather than just simply rendering a template - which means
      # all the current variables and params will be forgotten. But we still
      # need to pass information about the edit conflicts to the next action,
      # so we use the flash.
      #
      # Only primitive types (String, Array, Hash) can be saved in the flash;
      # we can't use it to pass a Time objec - so pass the time as a string.
      flash[:update_conflicts_since] = Time.at(params[name][:original_updated_at].to_i + 1).utc.to_s(:db)
    end
  end

  def load_conflicting_revisions(record)
    if flash[:update_conflicts_since]
      @conflicting_revisions = record.versions\
        .order("created_at ASC")\
        .where("created_at > '#{flash[:update_conflicts_since]}'")
    end
  end
end
