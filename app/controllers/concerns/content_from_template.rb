module ContentFromTemplate
  private

  # Used to prefill a form from a NoteTemplate.
  #
  # When the user wants to create an Evidence or Note from a pre-existing
  # template, then the parameter "template" in the query string will equal the
  # name of the template they want to use. Use @template_content@ to get the
  # NoteTemplate from the query params.
  def template_content
    NoteTemplate.find(params[:template]).content
  rescue Exception => e
    # Fail gracefully if the template can't be found; don't make the
    # whole action fail e.g. because of a mistake in the query string.
    if e.message == 'Not found!'
      return ''
    else
      raise e
    end
  end
end