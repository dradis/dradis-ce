# Add our current location to the Ruby load path
$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '.'))

# load environment and dependencies
require 'config/environment'

# add the dradis core tasks, and define the namespaces for import, export, and
# upload tasks
require File.expand_path('../lib/tasks/thorfile', __FILE__)

# a gemified plugin can also add Thor tasks
puts 'Loaded add-ons:'

Dradis::Plugins::list.sort_by(&:plugin_name).each do |plugin|
  puts "\t#{plugin.plugin_name} - #{plugin.plugin_description}"
  plugin.load_thor_tasks
end
