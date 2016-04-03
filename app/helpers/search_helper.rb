module SearchHelper
	def search_filter_path(options={})
  	exist_opts = {
    	q: params[:q],
      scope: params[:scope]
    }

  	options = exist_opts.merge(options)
    search_path(options)
	end

  # returns sanitized text snipet as span
  def text_snippet(text, term)
    snipet_value = format_match_row(text, term)
    content_tag :span, snipet_value, class: "search-matches"
  end

  # get only part of the text if text is
  # lerger than 300 chars
  def format_match_row(text, term)
    return text if text.length <= 300
    max_length = 300
    pos_start = text.index(term)
    pos_end = text.index(term) + term.length
    sanitize_text(pos_start, pos_end, max_length, text)
  end

  # calcuate what part of text to take based on searched term,
  # searched term must always be visible in snippet
  def sanitize_text(pos_start, pos_end, max_length, text)
    return text[pos_start...max_length] if pos_start == 0
    return text[(pos_end - max_length)..-1] if pos_end == text.length
    return text[pos_end - 300...pos_end] if pos_start > max_length
    return text[0..pos_end + (max_length - pos_end - 1)]
  end
end
