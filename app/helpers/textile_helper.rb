module TextileHelper
  def textile_default_data
    {
      form_url: form_textile_path,
      help_url: markup_help_textile_path,
      preview_url: textilize_textile_path,
      source_url: source_textile_path
    }
  end
end
