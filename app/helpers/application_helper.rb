module ApplicationHelper # :nodoc:
  def markup(text)
    return unless text.present?

    context = {}

    textile_pipeline = HTML::Pipeline.new [
      HTML::Pipeline::DradisFieldableFilter,
      HTML::Pipeline::DradisTextileFilter,
      HTML::Pipeline::SanitizationFilter,
      HTML::Pipeline::AutolinkFilter,
      HTML::Pipeline::DradisCodeHighlightFilter
    ], context

    result = textile_pipeline.call(text)
    result[:output].to_s.html_safe
  end

  def render_view_hooks(partial, feature = :addon, locals: {})
    Dradis::Plugins::with_feature(feature).sort_by(&:plugin_description).each do |plugin|
      begin
        plugin_path = ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.deconstantize(plugin.name))
        concat(render("#{plugin_path}/#{partial}", locals))
      rescue ActionView::MissingTemplate
      end
    end
    ;nil
  end
end
