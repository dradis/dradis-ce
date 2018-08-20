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
        ERB::Util.html_escape(@text)
      end
    end
  end
end
