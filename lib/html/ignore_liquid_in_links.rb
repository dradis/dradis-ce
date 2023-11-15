module HTML
  class IgnoreLiquidInLinks
    PROTOCOLS = %w{
      ed2k ftp http https irc mailto news gopher nntp telnet webcal xmpp
      callto feed svn urn aim rsync tag ssh sftp rtsp afs file
    }.join('|')
    LINK_RE = %r{ (?: ((?:#{PROTOCOLS}):)// | www\. ) [^\s<\u00A0"|]+ }ix

    class << self
      def call(line)
        line =~ LINK_RE
      end
    end
  end
end
