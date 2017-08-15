# Note that the old admin:paths:methodologies needs to be translated into the
# new admin:paths:templates:projects.

class SettingsAddProjectAndMethodologyPaths < ActiveRecord::Migration[5.1]
  def up
    new_value = Rails.root.join('templates', 'projects').to_s

    # If there was an old setting, honor it.
    if (old_setting = Configuration.find_by_name('admin:paths:methodologies'))
      new_value = old_setting.value
      old_setting.destroy
    end

    Configuration.create(:name => 'admin:paths:templates:projects', :value => new_value)
  end

  def down
    # regenerate the legacy setting
    if (current_setting = Configuration.find_by_name('admin:paths:templates:projects'))
      Configuration.create(:name => 'admin:paths:methodologies', :value => current_setting.value)
      current_setting.destroy
    end
  end
end
