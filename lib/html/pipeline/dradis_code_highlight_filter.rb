module HTML
  class Pipeline
    # HTML Filter that highlights post-processed Textile code blocks.
    #
    # Context options:
    #   n/a
    #
    # This filter does not write any additional information to the context hash.
    class DradisCodeHighlightFilter < Filter
      # Locate the %%{{}}%% sequence inside code blocks and highlight it (via
      # <mark> tags)
      def call
        doc.search('pre').each do |element|
          element.inner_html = '<code>' + element.text.gsub(/%%\{\{(.+)\}\}%%/i) do |match|
            %|<mark>#{$1}</mark>|
          end + '</code>'
        end
        doc
      end
    end
  end
end
