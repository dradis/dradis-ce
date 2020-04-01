module HTML
  class Pipeline
    # HTML Filter that highlights post-processed Textile elements.
    #
    # Context options:
    #   n/a
    #
    # This filter does not write any additional information to the context hash.
    class DradisCodeHighlightFilter < Filter
      REGEX = /\$\$\{\{(.+?)\}\}\$\$/

      # Locate the $${{}}$$ sequence and highlight it (via <mark> tags)
      def call
        doc.search('*').each do |node|
          content = node.to_html
          html    = content.gsub(REGEX) do |match|
            %|<mark>#{$1}</mark>|
          end

          node.replace(html)
        end

        doc
      end
    end
  end
end
