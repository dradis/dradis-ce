module SearchHelper
  def search_filter_path(options={})
    exist_opts = {
      q: params[:q],
      scope: params[:scope]
    }

    options = exist_opts.merge(options)
    project_search_path(current_project, options)
  end

  # returns sanitized text snippet as span
  def text_snippet(text, term)
    snipet_value = format_match_row(text, term)
    content_tag :span, snipet_value, class: "search-matches"
  end

  # Get only part of the text around the match if text is larger than 300 chars
  def format_match_row(text, query)
    return text if text.length <= 300
    max_length = 300

    # MySQL won't do case-sensitive LIKEs
    text_down  = text.downcase
    query_down = query.downcase

    pos_start = text_down.index(query_down)
    pos_end   = text_down.index(query_down) + query.length
    crop_text(pos_start, pos_end, max_length, text)
  end

  # Calculate what part of text to take based on the search term,
  # which must always be visible in the result
  def crop_text(pos_start, pos_end, max_length, text)
    return text[pos_start...max_length] if pos_start == 0
    return text[(pos_end - max_length)..-1] if pos_end == text.length
    return text[pos_end - 300...pos_end] if pos_start > max_length
    return text[0..pos_end + (max_length - pos_end - 1)]
  end
end
