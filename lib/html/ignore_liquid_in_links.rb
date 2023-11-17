module HTML
  class IgnoreLiquidInLinks
    PROTOCOLS = %w{
      ed2k ftp http https irc mailto news gopher nntp telnet webcal xmpp
      callto feed svn urn aim rsync tag ssh sftp rtsp afs file
    }.join('|')
    LINK_RE = %r{ (?: ((?:#{PROTOCOLS}):)// | www\. ) [^\s<\u00A0"|]+ }ix
    LIQUID_RAW_RE = /\{%\s*raw\s*%\}(.*?)\{%\s*endraw\s*%\}/

    class << self
      def call(text)
        lines = text.lines

        lines.map do |line|
          if line !~ LIQUID_RAW_RE && line =~ LINK_RE
            "{% raw %}#{line.chomp}{% endraw %}\n"
          else
            line
          end
        end
        lines.join
      end
    end
  end
end
