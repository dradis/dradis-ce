module ApplicationHelper # :nodoc:
  def markup(text)
    return unless text.present?

    context = { }

    textile_pipeline = HTML::Pipeline.new [
      HTML::Pipeline::DradisFieldableFilter,
      HTML::Pipeline::DradisTextileFilter,
      # HTML::Pipeline::DradisCodeHighlightFilter,
      HTML::Pipeline::AutolinkFilter
    ], context

    result = textile_pipeline.call(text)
    result[:output].to_s.html_safe
  end
end
