module ApplicationHelper # :nodoc:
  def markup(text, options = {})
    return unless text.present?

    context = {}

    # Note that future HTML::Pipeline versions have migrated from Sanitize -> Selma
    context[:whitelist] = HTML::Pipeline::Dradis::Sanitize::ALLOWLIST

    pipeline_filters = [
      HTML::Pipeline::Dradis::FieldableFilter,
      HTML::Pipeline::Dradis::TextileFilter,
      HTML::Pipeline::SanitizationFilter,
      HTML::Pipeline::AutolinkFilter,
      HTML::Pipeline::Dradis::CodeHighlightFilter
    ]

    if options[:liquid]
      context[:liquid_assigns] = liquid_assigns
      pipeline_filters.insert(1, HTML::Pipeline::Dradis::LiquidFilter)
    end

    if options[:filters].present?
      options[:filters].each do |index, filter|
        pipeline_filters.insert(index, filter)
      end
    end

    textile_pipeline = HTML::Pipeline.new pipeline_filters, context
    result = textile_pipeline.call(text)
    result[:output].to_s.html_safe
  end

  def render_view_hooks(partial, locals: {}, feature: :addon)
    Dradis::Plugins::with_feature(feature).sort_by(&:plugin_description).each do |plugin|
      begin
        plugin_path = ActiveSupport::Inflector.underscore(ActiveSupport::Inflector.deconstantize(plugin.name))
        concat(render("#{plugin_path}/#{partial}", locals))
      rescue ActionView::MissingTemplate
      end
    end
    ;nil
  end

  def spinner_tag(spinner_class: 'text-primary', align: 'center', inline: false)
    content_tag :div, class: "#{inline ? 'd-inline-flex' : 'd-flex' } align-items-center justify-content-#{align} spinner-container" do
      content_tag :div, nil, class: "spinner-border #{spinner_class}"
    end
  end
end
