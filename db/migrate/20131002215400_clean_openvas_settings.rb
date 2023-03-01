class CleanLegacyConfig < ActiveRecord::Migration[5.1]
  def up
    # This removes old settings that may exist in versions of Pro prior to v1.9
    %w{openvas:node_label}.each do |name|
      ::Configuration::find_by_name(name).try(:destroy)
    end
  end

  def down
    # we can't un-delete legacy settings
  end
end

klass_name = defined?(Dradis::Plugins::OpenVAS) ? 'CleanOpenVASSettings' : 'CleanOpenvasSettings'
Object.const_set(klass_name, CleanLegacyConfig)
