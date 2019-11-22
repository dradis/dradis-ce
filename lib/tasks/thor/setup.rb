# frozen_string_literal: true

class DradisTasks < Thor
  class Setup < Thor
    include Thor::Actions
    include ::Rails.application.config.dradis.thor_helper_module

    namespace 'dradis:setup'

    def self.source_root
      File.join(__dir__, '../templates')
    end

    desc 'configure', 'Creates the Dradis configuration files from their templates (see config/*.yml.template)'
    def configure
      # init the config files
      init_all = false
      Dir['config/*.template'].each do |template|
        config = File.join('config', File.basename(template, '.template'))
        if !(File.exists?(config))
          if (init_all)
            puts "Initilizing #{config}..."
            FileUtils.cp(template, config)
          else
            puts "The config file [#{template}] was found not to be ready to use."
            puts 'Do you want to initialize it? [y]es | [N]o | initialize [a]ll'
            response = STDIN.gets.chomp.downcase
            response = 'Y' if (response.empty? || !['y', 'n', 'a'].include?(response))

            if response == 'n'
              next
            else
              puts "Initilizing #{config}..."
              FileUtils.cp(template, config)
              if (response == 'a')
                init_all = true
              end
            end
          end
        end
      end
    end

    desc 'migrate', 'ensures the database schema is up-to-date'
    def migrate
      require 'config/environment'

      print '** Checking database migrations...                                    '
      ActiveRecord::Migrator.migrate('db/migrate/', nil)
      puts '[  DONE  ]'
    end

    desc 'seed', 'adds initial values to the database (i.e., categories and configurations)'
    def seed
      require 'config/environment'

      print '** Seeding database...                                                '
      require 'db/seeds'
      puts '[  DONE  ]'
    end

    desc 'welcome', 'adds initial content to the repo for demonstration purposes'
    def welcome
      # --------------------------------------------------------- Note template
      if NoteTemplate.pwd.exist?
        say 'Note templates folder already exists. Skipping.'
      else
        template 'note.txt', NoteTemplate.pwd.join('basic_fields.txt')
      end

      # ----------------------------------------------------------- Methodology
      if Methodology.pwd.exist?
        say 'Methodology templates folder already exists. Skipping.'
      else
        template 'methodology.xml', Methodology.pwd.join('owasp2017.xml')
      end

      # ---------------------------------------------------------- Project data
      detect_and_set_project_scope

      task_options.merge!(
        plugin: Dradis::Plugins::Projects::Upload::Template,
        default_user_id: 1
      )

      importer = Dradis::Plugins::Projects::Upload::Template::Importer.new(task_options)
      importer.import(file: template('project.xml'))

      # dradis:reset:database truncates the tables and resets the :id column so
      # we know the right node ID we're going to get based on the project.xml
      # structure.
      Dir.mkdir(Attachment.pwd.join('5'))
      template 'command-01.png', Attachment.pwd.join('5/command-01.png')
    end
  end
end
