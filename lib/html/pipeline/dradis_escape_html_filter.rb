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
      def call
        text = ERB::Util.html_escape(@text)

        # Add another newline between a field header and a bc.. block. We're
        # doing this for two reasons:
        # 1. To better handle valid bc.. blocks. Originally, bc.. blocks are
        #    only valid if the previous line is empty. The fieldable filter
        #    cheats the validity by ignoring newlines after the field header.
        # 2. The regex does not support a variable-length lookbehind. Simply
        #    put, the regex: (?<=\#\[.*\]\#\nbc\.\.) is not valid.
        field_regex = /(\#\[.+\]\#)(?:\r\n|\n)(bc\.\.)/
        text.gsub!(field_regex) do |match|
          match.sub(/(\r\n|\n)/, "\n\n")
        end


        # Match the text under bc./bc.. and links, following the textile rules
        regex = Regexp.union(
          /(?<=bc\. )(.*?)(?=(\r\n|\n){2})/m,
          /(?<=\nbc\.\. |\n\nbc\.\. |\Abc\.\.)(.*?)(?=(bc\.|bc\.\.|p\.|\z))/m,
          /&quot;(.*?)&quot;:(?:http|https)\:\/\/.+/
        )

        # Un-escape the matched strings
        text.gsub(regex) do |matched|
          CGI::unescapeHTML(matched)
        end
      end
    end
  end
end
