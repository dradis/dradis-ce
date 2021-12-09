# frozen_string_literal: true

class DradisTasks < Thor
  class Setup < Thor
    include Thor::Actions
    include Rails::Generators::Actions
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
      rake('db:migrate')
      puts '[  DONE  ]'
    end

    desc 'seed', 'adds initial values to the database (i.e., categories and configurations)'
    def seed
      require 'config/environment'

      print '** Seeding database...                                                '
      require 'db/seeds'
      puts '[  DONE  ]'
    end

    desc 'kit', 'Import files and projects from a specified Kit configuration file'
    method_option :file, required: true, type: :string, desc: 'full path to the Kit file to use.'
    def kit
      puts "** Importing kit..."
      KitImportJob.perform_now(file: options[:file], logger: default_logger)
      puts "[  DONE  ]"
    end

    desc 'welcome', 'adds initial content to the repo for demonstration purposes'
    def welcome
      kit_file = prepare_kit

      # Before we import the Kit we need at least 1 user
      User.create!(email: 'adama@dradisframework.com').id
      invoke 'dradis:setup:kit', [], file: kit_file.path
    end

    private
    def prepare_kit

      puts "** Creating kit..."
      welcome_kit = Tempfile.new(['welcome', '.zip'])
      Zip::File.open(welcome_kit.path, create: true) do |zipfile|

        zipfile.mkdir('kit')
        zipfile.mkdir('kit/templates/')
        zipfile.mkdir('kit/templates/methodologies/')
        zipfile.mkdir('kit/templates/notes/')
        zipfile.mkdir('kit/templates/projects/')

        methodology_template = File.join(self.class.source_root, 'methodology.xml')
        zipfile.add('kit/templates/methodologies/owasp2017.xml', methodology_template)

        note_template = File.join(self.class.source_root, 'note.txt')
        zipfile.add('kit/templates/notes/basic_fields.txt', note_template)

        project_package = prepare_project_package
        zipfile.add('kit/dradis-export-welcome.zip', project_package.path)
      end
      puts "[  DONE  ]"

      welcome_kit
    end

    def prepare_project_package
      project_package = Tempfile.new(['project', '.zip'])

      Zip::File.open(project_package.path, create: true) do |zipfile|
        project_template = File.join(self.class.source_root, 'project.xml')
        zipfile.add('dradis-repository.xml', project_template)

        # dradis:reset:database truncates the tables and resets the :id column so
        # we know the right node ID we're going to get based on the project.xml
        # structure.
        attachment_file = File.join(self.class.source_root, 'command-01.png')
        zipfile.mkdir('5/')
        zipfile.add('5/command-01.png', attachment_file)
      end

      project_package
    end
  end
end
