# Because we moved away from Bj for background processing (in favor of
# Redis/Resque), this migration fails because there is no Bj module.
#
# We've decided to keep the file in the repo for archeological interest.

class FixBjIndex < ActiveRecord::Migration[5.1]
  def up
    # If we skip the :length, as originally created by bj and run in MySQL it will
    # complain with a "Mysql2::Error: BLOB/TEXT column 'hostname' used in key
    # specification without a key length"
    #
    # See:
    #   http://stackoverflow.com/questions/10092188/rails-blob-text-column-used-in-key-specification-without-a-key-length

    # if index_exists?('bj_config', ['hostname', 'key'], :name => 'index_bj_config_on_hostname_and_key')
    #   remove_index('bj_config', name: 'index_bj_config_on_hostname_and_key')
    # end
    # add_index 'bj_config', ['hostname', 'key'], :name => 'index_bj_config_on_hostname_and_key', :unique => true, :length => {'hostname' => 32, 'key' => 32}
  end

  def down
    # remove_index('bj_config', name: 'index_bj_config_on_hostname_and_key')
    # add_index 'bj_config', ['hostname', 'key'], :name => 'index_bj_config_on_hostname_and_key', :unique => true
  end
end
