module MarkupHelper
  def editor_paths
    preview_params = {}
    preview_params[:project_id] = params[:project_id] if params[:project_id]

    {
      form_url: form_fields_path(format: :js),
      help_url: help_markup_path,
      preview_url: preview_markup_path(preview_params),
      source_url: source_fields_path
    }
  end
end
