%%{{}}%%
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
        doc.search('code').each do |element|
          # element.inner_html = element.text.gsub(/(https|http)?:\/\/.+\.(jpg|jpeg|bmp|gif|png)(\?\S+)?/i) do |match|
          #   %|<img src="#{match}" alt=""/>|
          # end
          element.inner_html = element.text.gsub(/%%\{\{(.+)\}\}%%/mi) do |match|
            %|<mark>#{$1}</mark>|
          end
        end
        doc
      end
    end
  end
end