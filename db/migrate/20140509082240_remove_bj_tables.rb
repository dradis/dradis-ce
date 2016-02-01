# After moving to a redis/resque-based background worker, we no longer need any
# of the old DB background tables.
#
# See:
#   20100914104742_create_delayed_jobs.rb
#   20101029150104_bj_migration.rb
#   20120131171008_bj_rails32_compatibility.rb
#
class RemoveBjTables < ActiveRecord::Migration
  def drop_table_if_exists(name)
    drop_table(name) if ActiveRecord::Base.connection.table_exists?(name)
  end
  def up
    drop_table_if_exists :delayed_jobs

    # At this stage in the game, Bj is no longer defined (we removed the files!)
    # Bj::Table.reverse_each{|table| table.down}
    # drop_table Bj::Table.table_name
    [
      :bj_config,
      :bj_job,
      :bj_job_archive,
      :bj_tables
    ].each do |table|
      drop_table_if_exists table
    end
  end

  def down
    say "The delayed_jobs and bj tables were deleted and cannot be restored. See #{__FILE__} for details."
  end
end
