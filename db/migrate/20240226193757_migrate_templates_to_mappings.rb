class MigrateTemplatesToMappings < ActiveRecord::Migration[7.0]
  def up
    MappingMigrationService.new.call
  end

  def down
    MappingMigrationService.new.reverse_migration
  end
end
