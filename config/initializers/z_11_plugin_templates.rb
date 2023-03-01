# Rails 5.2 now loads the environment on all db rake tasks. Previously it did
# not for setup or create. This means if the db doesn't exist this code will
# fail. Technically we shouldn't communicate with AR during initializers so this
# is workaround.
# https://github.com/rails/rails/issues/32870

# Unless the DB is already migrated, do nothing

Rails.application.reloader.to_prepare do
  if (ActiveRecord::Base.connection rescue false) && Configuration.table_exists? && Configuration.paths_templates.exist?
    # ---------------------------------------------------------------- 3.1 Upload
    template_dir = Configuration.paths_templates_plugins

    Dradis::Plugins::with_feature(:upload).each do |plugin|
      plugin.copy_templates(to: template_dir)
    end

    # ---------------------------------------------------------------- 3.2 Export
    template_dir = Configuration.paths_templates_reports
    Dradis::Plugins::with_feature(:export).each do |plugin|
      plugin.copy_templates(to: template_dir)
    end
  end
end
