class DradisTasks < Thor
  class Digest < Thor
    namespace     'dradis:digests'

    desc 'send', 'Send a daily digest to all users'
    def send
      print '** Sending digest to all users...'
    end

    desc 'send_instant', 'Send an instant digest to all users'
    def send_instant
      print '** Sending an instant digest to all users...'
    end
  end
end
