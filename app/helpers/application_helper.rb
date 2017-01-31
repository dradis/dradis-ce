module ApplicationHelper # :nodoc:
  def markup(text)
    # return unless text.present?
    #
    # output = text.dup
    # Hash[ *text.scan(/#\[(.+?)\]#[\r|\n](.*?)(?=#\[|\z)/m).flatten.collect{ |str| str.strip } ].keys.each do |field|
    #   output.gsub!(/#\[#{Regexp.escape(field)}\]#[\r|\n]/, "h4. #{field}\n\n")
    # end
    #
    # auto_link(RedCloth.new(output, [:filter_html, :no_span_caps]).to_html, :sanitize => false ).html_safe
    new_markup(text)
  end

  def new_markup(text)
    context = { }

    textile_pipeline = HTML::Pipeline.new [
      HTML::Pipeline::DradisFieldableFilter,
      HTML::Pipeline::DradisTextileFilter,
      HTML::Pipeline::DradisCodeHighlightFilter,
      HTML::Pipeline::AutolinkFilter
    ], context

    result = textile_pipeline.call(text)
    result[:output].to_s.html_safe
  end
end
