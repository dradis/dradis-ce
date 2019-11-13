# frozen_string_literal: true

# This file defines Dradis cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
#
# Learn more: http://github.com/javan/whenever

set :output, 'log/cron.log'
job_type :thor, 'cd :path && RAILS_ENV=:environment bundle exec thor :task :output'

Dir['./config/schedules/**/*.rb'].sort.each do |schedule|
  instance_eval IO.read(schedule)
end
