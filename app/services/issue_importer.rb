# This service manages the flow of importing issue from external sources by
# using Import plugins.
class IssueImporter
  attr_accessor :filter, :plugin

  def initialize(params)
    if params[:scope].present? and params[:filter].present?
      @plugin, @filter = find_plugin_and_filter(params)
      @params = params
    end
  end

  # It runs a query against one of the import plugins and returns a collection
  # of Result objects:
  #  [
  #    {title: 'Foo', description: 'bar', tags: [:private]},
  #    {title: 'Bar', description: 'foo', tags: [:public]},
  #  ]
  def query
    if @filter
      if @filter.respond_to?(:run)
        @filter.run(@params)
      elsif @filter.respond_to?(:query)
        @filter.query(@params)
      end
    else
      [{
        title: 'Invalid plugin/filter selection',
        description: "#[Title]#\nInvalid plugin/filter selection\n\n#[Description]#\nThe selected plugin/filter could not be found. You are not tampering with the request, are you?"
      }]
    end
  end


  private

  def find_plugin_and_filter(params)
    plugin = params[:scope]
    # TODO avoid .to_sym before matching against whitelist
    filter = params[:filter].to_sym

    if defined?(Plugins::Import) && Plugins::Import::included_modules.collect(&:name).include?(plugin)
      plugin = plugin.constantize

    elsif Dradis::Plugins::with_feature(:import).collect(&:plugin_name).collect(&:to_s).include?(plugin)
      plugin = plugin.to_sym
    else
      plugin = nil
    end


    if plugin
      if Dradis::Plugins::Import::Filters[plugin] && Dradis::Plugins::Import::Filters[plugin].keys.include?(filter)
        filter = Dradis::Plugins::Import::Filters[plugin][filter]
      elsif plugin::Filters::constants.include?(filter)
        filter = "#{plugin.name}::Filters::#{filter}".constantize
      end
    else
      filter = nil
    end

    return plugin, filter
  end
end
