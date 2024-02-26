class MigrateTemplatesToMappings < ActiveRecord::Migration[7.0]
  def change
    MappingMigrationService.new.call
  end
end
