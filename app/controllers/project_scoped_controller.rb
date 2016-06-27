class ProjectScopedController < AuthenticatedController
  include ActivityTracking

  before_action :set_current_project
  helper :snowcrash
  layout 'snowcrash'

  protected

  # Initialize the instance varables used in the sidebar for nodes pages
  # (@sorted_evidence and @sorted_notes, displayed in
  # `nodes/_sidebar.html.erb`.
  #
  # Used in node, evidence, note, and revision controllers.
  def initialize_nodes_sidebar
    # If you just tried to save an invalid Note, then that Note will be
    # included in @node.notes and will crash the sidebar (because the sidebar
    # won't be able to generate a route for a Note with no id) So filter out
    # Notes that haven't been saved:
    @sorted_notes    = @node.notes.sort_by(&:title).select(&:persisted?)
    @sorted_evidence = @node.evidence.sort_by { |e1| e1.issue.title }
  end

  def set_current_project
    @nodes = Node.in_tree
  end

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

  def load_conflicting_versions(record)
    if flash[:update_conflicts_since]
      @conflicting_versions = record.versions\
        .order("created_at ASC")\
        .where("created_at > '#{flash[:update_conflicts_since]}'")
    end
  end
end
