class DradisTasks < Thor
  class Gemfile < Thor
    namespace 'dradis:gemfile'

    desc 'update FILE', 'Updates the version or source of Dradis addons'
    method_option :version, aliases: '-v', desc: 'The version to assign to the addons ex. \'4.0.1\''
    method_option :branch, aliases: '-b', desc: 'The branch to assign to the addons ex. \'release-4.0.1\''
    def update(file)
      if options[:version] || options[:branch]
        update_gemfile(file, options)
      else
        puts 'ERROR: You need to specify :version or :branch'
        DradisTasks::Gemfile.command_help(Thor::Base.shell.new, 'update')
      end
    end

    private

    def update_gemfile(file, options)
      gemfile = File.read(file)

      updated_gemfile = gemfile.gsub(/['"](dradis(pro)?-\w*)['"], .*/) do |match|
        gem_name = /(dradis(pro)?-\w*)['"]/.match(match)[1]

        if options[:branch]
          "'#{gem_name}', github: 'dradis/#{gem_name}', branch: '#{options[:branch]}'"
        elsif options[:version]
          "'#{gem_name}', '~> #{options[:version]}'"
        end
      end

      File.write(file, updated_gemfile)
    end
  end
end
