class AddAdminToGlobalSettingNames < ActiveRecord::Migration
  def up
    %w[
      uploads_node
      emails_node
    ].each do |name|
      # in some weird cases, the settings won't be there yet (i.e. when
      # bootstrapping a new install in development, or in CI before the
      # db:seed task has run)
      config = Configuration.find_by_name(name)
      config.update_attribute(:name, "admin:#{name}") if config
    end
  end
  def down
    %w[
      uploads_node
      emails_node
    ].each do |name|
      Configuration.find_by_name("admin:#{name}").update_attribute(:name, name)
    end
  end
end
