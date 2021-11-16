# frozen_string_literal: true

require 'optparse'

ARGV << '-h' if ARGV.empty?

options = Hash.new(false)
OptionParser.new do |opts|
  opts.banner = 'Usage: ruby compat.rb [options]'

  opts.separator ''
  opts.separator 'Example:'
  opts.separator '    ruby update_gemfile.rb -f Gemfile.plugins -v 4.0.0'
  opts.separator '    ruby update_gemfile.rb -f Gemfile.plugins -g release-4.0.0'
  opts.separator ''
  opts.separator 'Options:'

  opts.on('-f GEMFILE', '--file GEMFILE', 'The Gemfile to update') { |o| options[:file] = o }
  opts.on('-v VERSION', '--version VERSION', 'The version to assign') { |o| options[:version] = o }
  opts.on('-b BRANCH', '--branch BRANCH', 'The branch to assign') { |o| options[:branch] = o }

  opts.on_tail('-h', '--help', 'Show this message') do
    puts opts
    exit
  end
end.parse!

def term_puts(message)
  puts `
    GREEN='\033[0;32m'
    NC='\033[0m'
    echo "${GREEN}#{message}${NC}"
  `
end

exit 'You need to pass a Gemfile to work on' unless options[:file]

gemfile = File.read(options[:file])

updated_gemfile = gemfile.gsub(/['"](dradis(pro)?-\w*)['"], .*/) do |match|
  gem_name = /(dradis(pro)?-\w*)['"]/.match(match)[1]

  if options[:branch]
    "'#{gem_name}', github: 'dradis/#{gem_name}', branch: '#{options[:branch]}'"
  elsif options[:version]
    "'#{gem_name}', '~>#{options[:version]}'"
  end
end

File.write(options[:file], updated_gemfile)
