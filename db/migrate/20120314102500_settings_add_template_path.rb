class SettingsAddTemplatePath < ActiveRecord::Migration[5.1]
  def up
    # Add new configurations
    Configuration.create(:name => 'admin:paths:plugin_templates', :value => Rails.root.join('templates', 'plugins').to_s)
  end

  def down
    # we can't un-delete legacy settings
    Configuration.find_by_name('admin:paths:plugin_templates').try(:destroy)
  end
end