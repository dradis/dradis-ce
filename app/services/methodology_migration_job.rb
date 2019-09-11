class MethodologyMigrationJob < ApplicationJob
  queue_as :dradis_migrate

  def perform(project_id:)
    # FIXME: migrate logs#uid to uuid ?
    logger = Log.new(uid: (Log.maximum(:uid) || 0) + 1)

    # find methodologies to be migrated
    methodologylib = Project.find(project_id).methodology_library
    already_migrated_ids = methodologylib.properties[:already_migrated] ||= []
    methodologies =
      methodologylib.notes.where.not(id: already_migrated_ids).map do |n|
        Methodology.new(filename: n.id, content: n.text)
      end

    logger.write do
      "Migrating #{methodologies.count} methodologies on project #{project_id}"
    end

    migration = MethodologyMigrationService.new(project_id)
    begin
      methodologies.each do |methodology|
        migration.migrate(methodology)
        # if migration worked, note that methodology as migrated
        methodologylib.properties[:already_migrated] |= [methodology.filename]
      end
    ensure
      # unmark current migration as being performed
      if methodologylib.properties[:migration_job_id] == self.job_id
        methodologylib.properties.delete(:migration_job_id)
      end

      methodologylib.save!
    end

    logger.write { "Done." }
  end
end
