# frozen_string_literal: true

class DradisTasks < Thor
  class Logs < Thor
    namespace 'dradis:logs'

    desc 'clean DAYS', 'delete all logs older than DAYS days (default 7)'
    def clean(days = 7)
      puts 'Clearing old Logs...'
      logs  = Log.where('created_at < (?)', days.to_i.days.ago)
      count = logs.count
      logs.destroy_all
      puts "Deleted #{count} Log#{"s" if count != 1}"
    end
  end
end
