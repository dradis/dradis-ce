# frozen_string_literal: true

class DradisTasks < Thor
  class Reset < Thor
    include Thor::Actions
    include Rails::Generators::Actions

    namespace 'dradis:reset'

    desc 'attachments', 'removes all attachments'
    def attachments
      print '** Deleting all attachments...                                        '
      FileUtils.rm_rf(Dir.glob(Attachment::AttachmentPwd.join('*')))
      puts(Dir.glob(Attachment::AttachmentPwd.join('*')).empty? ? '[  DONE  ]' : '[ FAILED ]')
    end

    desc 'database', 'removes all data from a dradis repository, except configurations'
    def database
      return if defined?(Dradis::Pro)

      require 'config/environment'

      puts '** Cleaning database...'
      rake('db:drop')
      rake('db:prepare')
      rake('db:seed')
      puts '   [  DONE  ]'
    end

    desc 'logs', 'removes all log files'
    def logs
      print '** Deleting all log files...                                          '
      FileUtils.rm_rf(Dir.glob('log/*.log'))
      puts(Dir.glob('log/*.log').empty? ? '[  DONE  ]' : '[ FAILED ]')
    end

    desc 'password', 'Set a new shared password to access the web interface'
    def password()
      require 'config/environment'

      say 'Changing password for Dradis server.'
      password = ask 'Enter new Dradis password:'
      confirmation = ask 'Retype new Dradis password:'

      if !password.blank? && password == confirmation
        Configuration.find_or_create_by(name: 'admin:password').update_attribute(:value, ::BCrypt::Password.create(password))
        say('Password Changed.', Thor::Shell::Color::GREEN)
      else
        say('Passwords do not match. Password Unchanged.', Thor::Shell::Color::RED)
      end
    end
  end
end
