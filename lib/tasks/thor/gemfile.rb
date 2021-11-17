class DradisTasks < Thor
  class Gemfile < Thor
    include Thor::Actions
    namespace 'dradis:gemfile'

    desc 'update FILE', 'Updates the version or source of Dradis addons'
    method_option :version, aliases: '-v', desc: 'The version to assign to the addons ex. \'4.0.1\''
    method_option :branch, aliases: '-b', desc: 'The branch to assign to the addons ex. \'release-4.0.1\''
    def update(file)
      if options[:branch]
        gsub_file file, /['"](dradis(pro)?-\w*(?!.*engines\/))['"], .*/, "'\\1', github: 'dradis/\\1', branch: '#{options[:branch]}'"
      elsif options[:version]
        gsub_file file, /['"](dradis(pro)?-\w*(?!.*engines\/))['"], .*/, "'\\1', '~> #{options[:version]}'"
      else
        puts 'ERROR: You need to specify :version or :branch'
        DradisTasks::Gemfile.command_help(Thor::Base.shell.new, 'update')
      end
    end
  end
end
