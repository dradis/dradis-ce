# FIXME: Core::Plugins::Upload::Base should provide a helper that could
# be used to copy all default files across from the plugin's folder to
# the app's folder.
#
# When such facility exists we can replace the content of this loop with a
# simple call to (for instance) <plugin>.copy_templates


# Unless the DB is already migrated, do nothing
if Configuration.table_exists?
  plugin_dir = nil
  source_dir = nil
  destination_dir = nil
  template_dir = Configuration.paths_templates_plugins

  basename = nil
  source_file = nil
  destination_file = nil


  # ------------------------------------------ 3. New-style Dradis::Plugin gems

  # ---------------------------------------------------------------- 3.1 Upload
  template_dir = Configuration.paths_templates_plugins

  # First, lets migrate any existing templates from plugins we've removed from
  # ./vendor/
  [
    ['burp_upload', 'burp'],
    ['nessus_upload', 'nessus'],
    ['nexpose_upload', 'nexpose'],
    ['nmap_upload', 'nmap'],
    ['openvas_upload', 'open_vas'],
    ['qualys_upload', 'qualys']
  ].each do |old_dir, new_dir|
    source_dir = File.join(template_dir, old_dir)
    destination_dir = File.join(template_dir, new_dir)

    if Dir.exist?(source_dir)
      FileUtils.mv source_dir, destination_dir
    end
  end

  Dradis::Plugins::with_feature(:upload).each do |plugin|
    plugin.copy_templates(to: template_dir)
  end

  # ---------------------------------------------------------------- 3.2 Export
  template_dir = Configuration.paths_templates_reports
  Dradis::Plugins::with_feature(:export).each do |plugin|
    plugin.copy_templates(to: template_dir)
  end
end
