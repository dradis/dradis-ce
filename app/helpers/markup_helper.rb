module MarkupHelper
  def editor_paths
    {
      form_url: main_app.form_fields_path(format: :js),
      help_url: main_app.help_markup_path,
      preview_url: main_app.preview_markup_path,
      source_url: main_app.source_fields_path
    }
  end
end
