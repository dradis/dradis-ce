module HTML
  class Pipeline
    # Simple filter that HTML-escapes the text
    #
    # html-pipeline's own PlainTextInputFilter escapes HTML, but it also wraps
    # the text in a <div> which means the output can't be processed correctly
    # by DradisTextileFilter later. (PlainTextInputFilter also uses the
    # escape_utils gem which is faster than ERB::Util but means we'd have to
    # worry about yet another dependency with native extensions.)
    #
    # Context options:
    #   n/a
    #
    # This filter does not write any additional information to the context hash.
    class DradisEscapeHTMLFilter < TextFilter
      PROTOCOLS = %w{
        ed2k ftp http https irc mailto news gopher nntp telnet webcal xmpp
        callto feed svn urn aim rsync tag ssh sftp rtsp afs file
      }

      def call
        text = ERB::Util.html_escape(@text)

        # Match the text under bc./bc.. and links, following the textile rules
        regex = Regexp.union(
          /(?<=bc\. )(.*?)(?=(\r\n|\n){2})/m,
          /(?<=bc\.\. )(.*?)(?=(bc\.|bc\.\.|p\.|\z))/m,
          /&quot;.*&quot;:(?:#{PROTOCOLS.join('|')})\:\/\/.+/
        )

        # Un-escape the matched strings
        text.gsub(regex) do |matched|
          CGI::unescapeHTML(matched)
        end
      end
    end
  end
end
