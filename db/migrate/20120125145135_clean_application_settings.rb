class CleanApplicationSettings < ActiveRecord::Migration[5.1]
  def up
    # This removes old settings that may exist in versions of Pro prior to v1.4
    %w{password paths:methodologies}.each do |name|
      ::Configuration::find_by_name(name).try(:destroy)
    end
    # Add new configurations
    Configuration.create(:name=>'admin:signups_enabled', :value=>'1')
  end

  def down
    # we can't un-delete legacy settings
    Configuration.find_by_name('admin:signups_enabled').try(:destroy)
  end
end
