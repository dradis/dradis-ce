if ReportTemplateProperties.table_exists?
  (Dradis::Plugins.with_feature(:export) - [
    Dradis::Plugins::CSV::Engine,
    Dradis::Plugins::Projects::Engine
  ]).each do |plugin|
    plugin.plugin_templates.each do |template|
      ReportTemplateProperties.find_or_initialize_by(
        template_file: File.basename(template)
      ).update_attributes!(
        plugin_name: plugin.plugin_name
      )
    end
  end
end
