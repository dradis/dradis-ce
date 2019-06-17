module HTML
  class Pipeline
    # HTML Filter that highlights post-processed Textile code blocks.
    #
    # Context options:
    #   n/a
    #
    # This filter does not write any additional information to the context hash.
    class DradisCodeHighlightFilter < Filter
      REGEX = /\$\$\{\{(.+)\}\}\$\$/

      # Locate the $${{}}$$ sequence inside code blocks and highlight it (via
      # <mark> tags)
      def call
        doc.search('pre').each do |element|
          pre.search('code').each do |node|
            content = node.to_html
            html    = content.gsub(REGEX) do |match|
              %|<mark>#{$1}</mark>|
            end

            node.replace(html)
          end
        end

        doc
      end
    end
  end
end
