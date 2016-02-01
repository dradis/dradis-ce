# Because we moved away from Bj for background processing (in favor of
# Redis/Resque), this migration fails because there is no Bj module.
#
# We've decided to keep the file in the repo for archeological interest.

#
# Bj is incompatible with Rails 3.2 out of the box. We need a dummy table to
# bridge that gap.
#
# See the details in vendor/plugins/bj/lib/bj/table.rb
#

class BjRails32Compatibility < ActiveRecord::Migration
  def change
    #create_table Bj::Table.table_name
  end
end
