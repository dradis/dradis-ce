require 'resque/tasks'

# See http://railscasts.com/episodes/271-resque
task "resque:setup" => :environment do
  ENV['QUEUE'] ||= '*'
end
