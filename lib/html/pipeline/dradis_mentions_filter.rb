module HTML
  class Pipeline
    # HTML Filter that replaces mentions with avatar images and names
    #
    # Context options:
    #   mention_matchers: rules for replacing mentions with avatar images
    #
    # This filter does not write any additional information to the context hash.
    class DradisMentionsFilter < Filter
      def call
        matcher, rules = context[:mention_matcher]
        doc.search('.//text()').each do |node|
          text = node.text

          html = text.gsub matcher, rules
          node.replace html
        end

        doc
      end
    end
  end
end
