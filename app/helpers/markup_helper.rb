module MarkupHelper
  def editor_paths
    {
      form_url: form_fields_path(format: :js),
      help_url: help_markup_path,
      preview_url: preview_markup_path,
      source_url: source_fields_path
    }
  end
end
