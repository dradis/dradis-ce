class DradisTasks < Thor
  class Digest < Thor
    namespace     'dradis:digests'

    desc 'send', 'Send a daily digest to all users'
    def send_digests
      print '** Sending digest to all users...'
      DigestMailer.send_digests
    end

    desc 'send_instant', 'Send an instant digest to all users'
    def send_instants
      print '** Sending an instant digest to all users...'
      DigestMailer.send_instants
    end
  end
end
