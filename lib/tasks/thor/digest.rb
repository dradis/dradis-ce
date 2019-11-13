class DradisTasks < Thor
  class Digest < Thor
    namespace 'dradis:digests'

    desc 'send_dailies', 'Send a daily digest to all users'
    def send_dailies
      print '** Sending digest to all users...'
      DigestSender.send_dailies
    end

    desc 'send_instants', 'Send an instant digest to all users'
    def send_instants
      print '** Sending an instant digest to all users...'
      DigestSender.send_instants
    end
  end
end
