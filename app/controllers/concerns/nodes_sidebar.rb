module NodesSidebar
  # This should be called in a before_action for any controller action which
  # will render the 'nodes/sidebar' partial as part of its layout
  def initialize_nodes_sidebar
    # If you just tried to save an invalid Note, then that Note will be
    # included in @node.notes and will crash the sidebar (because the sidebar
    # won't be able to generate a route for a Note with no id) So filter out
    # Notes that haven't been saved:
    @sorted_notes    = @node.notes.select(&:persisted?).sort_by(&:title)
    @sorted_evidence = @node.evidence.select(&:persisted?).sort_by(&:title)
  end
end
