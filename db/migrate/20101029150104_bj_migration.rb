# Because we moved away from Bj for background processing (in favor of
# Redis/Resque), this migration fails because there is no Bj module.
#
# We've decided to keep the file in the repo for archeological interest.
class BjMigration < ActiveRecord::Migration
  def self.up
    #Bj::Table.each{|table| table.up}
  end
  def self.down
    #Bj::Table.reverse_each{|table| table.down}
  end
end
