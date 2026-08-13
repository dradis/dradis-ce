require 'cgi'
require 'securerandom'

HTML::Pipeline.require_dependency('redcloth', 'RedCloth')

module HTML
  class Pipeline
    module Dradis
      # HTML Filter that converts Textile text into HTML and converts into a
      # DocumentFragment.
      #
      # This filter does not write any additional information to the context hash.
      #
      # NOTE we use this instead of html-pipeline's own TextileFilter because
      # a) we want to pass the 'no_span_caps' option to RedCloth (otherwise
      #   things like URLs get messed up, see e.g. the specs).
      # b) the output needs to be wrapped in a <div> to make the pipeline work
      #    correctly, we can't add this <div> at an earlier point in the pipeline
      #    because then RedCloth can't parse the Textile correctly.
      class TextileFilter < TextFilter
        # RedCloth requires the closing '@' of an inline code span to be
        # immediately followed by a non-word character, and matches the
        # first '@' satisfying that rule as the closer. An email address
        # inside a span (e.g. '@admin@starfleet.com@') has an embedded '@'
        # that RedCloth may treat as (part of) the closer, so it either
        # abandons the whole span or mis-parses it (e.g. a dotted local
        # part like '@first.last@starfleet.com@' gets truncated). We avoid
        # this entirely by swapping email-shaped spans for inert
        # placeholders before RedCloth ever sees them, then restoring the
        # placeholders afterwards: as <code> in rendered text, as literal
        # '@...@' inside a <pre> block (e.g. Textile's `bc.` blocks, where
        # RedCloth intentionally leaves such spans verbatim) or wherever
        # inline code is disabled (comments), and as plain text inside any
        # HTML attribute value (e.g. a URL generated from Textile link
        # syntax) so we never corrupt markup we don't render as text.
        EMAIL_INLINE_CODE_PATTERN = /@([\w+\-.]+@[\w-]+(?:\.[\w-]+)+)@/
        EMAIL_PLACEHOLDER_PREFIX = 'dradisemailcode'
        EMAIL_PLACEHOLDER_PATTERN = /#{EMAIL_PLACEHOLDER_PREFIX}[a-f0-9]{16}/

        def call
          text, placeholders = protect_email_inline_code(@text)
          parser = RedCloth.new(text, [:filter_html, :no_span_caps])

          doc = if context[:no_inline_code]
            restore_email_placeholders(parser.to(HTML::NoInlineCodeTextileFormatter), placeholders, code_wrap: false)
          else
            restore_email_placeholders(parser.to_html, placeholders, code_wrap: true)
          end

          "<div>#{doc}</div>"
        end

        private

        def protect_email_inline_code(text)
          placeholders = {}

          protected_text = text.gsub(EMAIL_INLINE_CODE_PATTERN) do
            token = "#{EMAIL_PLACEHOLDER_PREFIX}#{SecureRandom.hex(8)}"
            placeholders[token] = Regexp.last_match(1)
            token
          end

          [protected_text, placeholders]
        end

        def restore_attribute_value(value, placeholders)
          value.gsub(EMAIL_PLACEHOLDER_PATTERN) { |token| "@#{placeholders.fetch(token)}@" }
        end

        def restore_email_placeholders(html, placeholders, code_wrap:)
          return html if placeholders.empty?

          fragment = Nokogiri::HTML::DocumentFragment.parse(html)

          fragment.xpath('.//text()').each do |node|
            next unless node.content.match?(EMAIL_PLACEHOLDER_PATTERN)

            wrap_in_code = code_wrap && node.ancestors('pre').none?
            node.replace(restore_text_node(node.content, placeholders, wrap_in_code))
          end

          fragment.css('*').each do |element|
            element.attribute_nodes.each do |attribute|
              next unless attribute.value.match?(EMAIL_PLACEHOLDER_PATTERN)
              attribute.value = restore_attribute_value(attribute.value, placeholders)
            end
          end

          fragment.to_html
        end

        def restore_text_node(text, placeholders, wrap_in_code)
          CGI.escapeHTML(text).gsub(EMAIL_PLACEHOLDER_PATTERN) do |token|
            email = placeholders.fetch(token)
            wrap_in_code ? "<code>#{email}</code>" : "@#{email}@"
          end
        end
      end
    end
  end
end
