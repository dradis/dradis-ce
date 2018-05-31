# FIXME: Core::Plugins::Upload::Base should provide a helper that could
# be used to copy all default files across from the plugin's folder to
# the app's folder.
#
# When such facility exists we can replace the content of this loop with a
# simple call to (for instance) <plugin>.copy_templates


# Unless the DB is already migrated, do nothing
if Configuration.table_exists?
  # ---------------------------------------------------------------- 3.1 Upload
  template_dir = Configuration.paths_templates_plugins
  Dradis::Plugins::with_feature(:upload).each do |plugin|
    plugin.copy_templates(to: template_dir)
  end

  # ---------------------------------------------------------------- 3.2 Export
  if !Rails.env.production?
    template_dir = Configuration.paths_templates_reports
    Dradis::Plugins::with_feature(:export).each do |plugin|
      plugin.copy_templates(to: template_dir)
    end
  end
end
