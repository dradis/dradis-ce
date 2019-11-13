# This file defines Dradis cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
#
# Learn more: http://github.com/javan/whenever

set :output, 'log/cron.log'
job_type :thor, 'cd :path && RAILS_ENV=:environment bundle exec thor :task :output'

every 10.minutes do
  thor 'dradis:digests:send_instants'
end

every 1.day, at: '9:00' do
  thor 'dradis:digests:send_dailies'
end
