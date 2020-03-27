module TextileHelper
  def textile_form_urls
    {
      form_url: form_path,
      help_url: markup_path,
      preview_url: preview_path,
      source_url: source_path
    }
  end
end
