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
        output = []

        lines.each_with_index do |line, index|
          # check that it doesn't yet have {% raw %} tags and is a url
          if line !~ LIQUID_RAW_RE && line =~ LINK_RE
            output << "{% raw %}#{line.chomp}{% endraw %}\n"
          else
            output << line
          end
        end
        output.join
      end
    end
  end
end
