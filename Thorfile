# Add our current location to the Ruby load path
$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '.'))

# add the dradis core tasks, and define the namespaces for import, export, and
# upload tasks
require File.expand_path('../lib/tasks/thorfile', __FILE__)

# a plugin can add additional tasks to Thor by declaring tasks/thorfile.rb in
# its plugin directory - so we can keep a plugin's command line tasks bundled
# with the plugin
Dir.glob('vendor/plugins/*/lib/tasks/thorfile.rb').each do |thorfile|
  require thorfile
end


# a gemified plugin can also add Thor tasks
require 'config/environment'

puts 'Loaded add-ons:'

Dradis::Plugins::list.sort_by(&:plugin_name).each do |plugin|
  puts "\t#{plugin.plugin_name} - #{plugin.plugin_description}"
  plugin.load_thor_tasks
end
