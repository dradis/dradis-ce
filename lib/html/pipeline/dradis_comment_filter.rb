module HTML
  class Pipeline
    # HTML Filter that santizes comments with simple rails filters
    #
    # Context options:
    #   n/a
    #
    # This filter does not write any additional information to the context hash.
    class DradisCommentFilter < Filter
      include ActionView::Helpers::TextHelper

      def call
        doc.search('.//text()').each do |node|
          text = node.text

          node.replace simple_format(
            ERB::Util.html_escape(text)
          )
        end

        doc
      end
    end
  end
end
