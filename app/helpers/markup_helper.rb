module MarkupHelper
  def editor_paths
    preview_params = {}
    preview_params[:project_id] = params[:project_id] if params[:project_id]

    {
      form_url: main_app.form_fields_path(format: :js),
      help_url: main_app.help_markup_path,
      preview_url: @form_preview_path ||= main_app.preview_markup_path(preview_params),
      source_url: main_app.source_fields_path
    }
  end
end
