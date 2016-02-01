class CleanPluginSettings < ActiveRecord::Migration
  def up
    %w[
      admin:paths:plugin_templates
      admin:uploads_node
    ].each do |name|
      if config = Configuration.find_by_name(name)
        config.destroy
      end
    end
  end

  def down
    Configuration.find_or_create_by_name('admin:uploads_node', value: 'Uploaded files')
    Configuration.find_or_create_by_name('admin:plugin_templates', value: Rails.root.join('templates', 'plugins').to_s)
  end
end
