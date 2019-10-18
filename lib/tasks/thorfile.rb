class DradisTasks < Thor
  namespace       'dradis'

  desc      'backup', 'creates a backup of your current repository'
  long_desc 'Creates a backup of the current repository, including all nodes, notes and ' +
            'attachments as a zipped archive. The backup can be imported into another ' +
            "dradis instance using the 'Project Package Upload' option."
  method_option   :path, :type => :string, :desc => 'the backup file destination directory'
  def backup
    require 'config/environment'

    invoke 'dradis:plugins:projects:export:package'
  end

  desc      'reset', 'resets your local dradis repository'
  long_desc 'Resets your dradis repository, removing all nodes, notes and attachments and log files ' +
            "so it is ready to start a new project.\n\nA backup of the current repository "+
            'will be taken before anything is removed.'
  method_option   :file, :type => :string, :desc => 'the backup file to create, or directory to create it in'
  method_option   :no_backup, :type => :boolean, :desc => 'do not create a backup of the current repository'
  def reset
    invoke 'dradis:setup:configure', [], []
    invoke 'dradis:setup:migrate', [], []

    invoke 'dradis:backup', [], options            unless options.no_backup

    invoke 'dradis:reset:attachments', [], []
    invoke 'dradis:reset:database', [], []
    invoke 'dradis:setup:seed', [], []
    invoke 'dradis:reset:logs', [], []
  end

  desc 'server', 'start dradis server'
  method_option   :p, :type => :string, :desc => 'specify the port to listen to (default 3004)'
  method_option   :b, :type => :string, :desc => 'bind to a specific IP address (default 0.0.0.0)'
  method_option   :d, :type => :boolean, :desc => 'run in the background'
  method_option   :P, :type => :string, :desc => 'specify the location of the PID file (default tmp/pids)'
  def server
    require 'rubygems'

    ARGV.shift        # remove dradis:server from the command-line arguments
    ARGV.unshift 's'  # add 's' to the beginning of the command-line arguments,
                      # because we want a server

    gem 'rails', '>= 0'
    # now that we've massaged the arguments a little, we let Rails take over and
    # do its magic (this is essentially invoking 'rails s' with all the options
    # passed into Thor
    load Gem.bin_path('rails', 'rails', '>= 0')
  end

  desc 'version', 'displays the version of the dradis server'
  def version
    require 'lib/core/version'
    puts Core::VERSION::string
    puts Core::Pro::VERSION::string
  end

  class Import < Thor; end
  class Export < Thor; end
  class Upload < Thor; end
end
