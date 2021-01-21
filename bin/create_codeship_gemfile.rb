# Auto-generate the Gemfile to be used on Codeship. Replace relative paths
# using "path:" with instructions to pull the gems from Github.
#
# This script is run on Codeship before it runs `bundle install`. See See
# https://codeship.com/projects/12691/configure_tests

gemfile = File.read("./Gemfile")

cs_gemfile = gemfile.gsub(/path:.*\.\.\/dradis.*['"]/) do |match|
  gem_name = /(dradis\-.*)['"]/.match(match)[1]
  "github: \"dradis/#{gem_name}\""
end

File.write("./Gemfile.codeship", cs_gemfile)
