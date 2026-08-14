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

        # A contiguous non-whitespace run containing '://' is a URL, whether
        # bare or the target of Textile link syntax ("text":URL). RedCloth
        # already handles an embedded '@...@' correctly in both cases on its
        # own, so we leave those alone rather than protecting them: bare
        # URLs stay one unbroken string for AutolinkFilter to link as a
        # whole, instead of being split into link/code fragments by an
        # email we protected and later restored as <code>.
        BARE_URL_PATTERN = %r{\S*://\S+}

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
          url_ranges = text.to_enum(:scan, BARE_URL_PATTERN).map { Regexp.last_match.begin(0)...Regexp.last_match.end(0) }
          placeholders = {}

          protected_text = text.gsub(EMAIL_INLINE_CODE_PATTERN) do
            match = Regexp.last_match
            next match[0] if url_ranges.any? { |range| range.cover?(match.begin(0)) }

            token = "#{EMAIL_PLACEHOLDER_PREFIX}#{SecureRandom.hex(8)}"
            placeholders[token] = match[1]
            token
          end

          [protected_text, placeholders]
        end

        def restore_attribute_value(value, placeholders, placeholder_pattern)
          value.gsub(placeholder_pattern) { |token| "@#{placeholders.fetch(token)}@" }
        end

        # Matches only the placeholder keys generated for this render, not the
        # general placeholder shape, so user text that happens to look like a
        # placeholder (e.g. a pasted 'dradisemailcode...' string) is left
        # untouched instead of raising KeyError on the fetch below.
        def restore_email_placeholders(html, placeholders, code_wrap:)
          return html if placeholders.empty?

          placeholder_pattern = Regexp.union(placeholders.keys)

          fragment = Nokogiri::HTML::DocumentFragment.parse(html)

          fragment.xpath('.//text()').each do |node|
            next unless node.content.match?(placeholder_pattern)

            wrap_in_code = code_wrap && node.ancestors('pre').none?
            node.replace(restore_text_node(node.content, placeholders, placeholder_pattern, wrap_in_code))
          end

          fragment.css('*').each do |element|
            element.attribute_nodes.each do |attribute|
              next unless attribute.value.match?(placeholder_pattern)
              attribute.value = restore_attribute_value(attribute.value, placeholders, placeholder_pattern)
            end
          end

          fragment.to_html
        end

        def restore_text_node(text, placeholders, placeholder_pattern, wrap_in_code)
          CGI.escapeHTML(text).gsub(placeholder_pattern) do |token|
            email = placeholders.fetch(token)
            wrap_in_code ? "<code>#{email}</code>" : "@#{email}@"
          end
        end
      end
    end
  end
end
