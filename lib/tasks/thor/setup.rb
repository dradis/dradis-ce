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

    desc 'kit', 'Import files and projects from a specified Kit configuration file'
    method_option :file, required: true, type: :string, desc: 'full path to the Kit file to use.'
    def kit
      puts "** Importing kit..."
      KitImportJob.perform_now(options[:file], logger: default_logger)
      puts "[  DONE  ]"
    end

    desc 'welcome', 'adds initial content to the repo for demonstration purposes'
    def welcome
      prepare_kit
      # Before we import the Kit we need at least 1 user
      User.create!(email: 'adama@dradisframework.com').id
      invoke 'dradis:setup:kit', [], file: File.join(self.class.source_root, 'welcome')
    end

    private
    def prepare_kit
      old_package = File.join(self.class.source_root, 'welcome/kit/dradis-export-welcome.zip')
      FileUtils.unlink old_package if File.exist?(old_package)
      new_package = prepare_project_package
      FileUtils.cp new_package.path, old_package
    end

    def prepare_project_package

      puts "** Creating project package..."
      # Because it's a Temfile, it will be garbage-collected on thor exit
      project_package = Tempfile.new(['project', '.zip'])
      Zip::File.open(project_package.path, create: true) do |zipfile|
        project_template = File.join(self.class.source_root, 'welcome/project/dradis-repository.xml')
        zipfile.add('dradis-repository.xml', project_template)

        # dradis:reset:database truncates the tables and resets the :id column so
        # we know the right node ID we're going to get based on the project.xml
        # structure.
        attachment_file = File.join(self.class.source_root, 'welcome/project/5/command-01.png')
        zipfile.mkdir('5/')
        zipfile.add('5/command-01.png', attachment_file)
      end
      puts "[  DONE  ]"

      project_package
    end
  end
end
