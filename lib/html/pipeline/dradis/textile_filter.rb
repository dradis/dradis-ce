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
        # The URI::MailTo::EMAIL_REGEXP uses anchors: \A/\z that we don't need.
        EMAIL_PATTERN = /#{URI::MailTo::EMAIL_REGEXP.source.delete_prefix('\A').delete_suffix('\z')}/

        # U+FDD0 is a Unicode noncharacter: the standard guarantees it can
        # never legitimately appear in interchanged text, so it's safe to
        # use as a marker with a plain global find/replace -- no lookup
        # table, no risk of colliding with real content. On the vanishingly
        # unlikely chance input already contains this exact codepoint, we
        # degrade gracefully (it's rendered back as a literal '@') rather
        # than raising.
        SENTINEL_CHAR = "\uFDD0"

        # RedCloth leaves instances of '@...@' on links alone so the Autolinker
        # can do its thing. So for those cases, we don't perform the sentinel
        # character replacement. Otherwise, RedCloth will detect these as inline
        # code and add unnecessary <code></code> tags.
        BARE_URL = %r{\S*://\S+}

        def call
          parser = RedCloth.new(protect_email_inline_code(@text), [:filter_html, :no_span_caps])

          doc = if context[:no_inline_code]
            parser.to(HTML::NoInlineCodeTextileFormatter)
          else
            parser.to_html
          end

          "<div>#{doc.gsub(SENTINEL_CHAR, '@')}</div>"
        end

        private

        # RedCloth requires the closing '@' of an inline code span to be
        # immediately followed by a non-word character, and matches the
        # first '@' satisfying that rule as the closer. An email address
        # inside a span (e.g. '@admin@starfleet.com@') has an embedded '@'
        # that RedCloth may treat as (part of) the closer, so it either
        # abandons the whole span or mis-parses it (e.g. a dotted local
        # part like '@first.last@starfleet.com@' gets truncated). We avoid
        # this entirely by hiding every email's inner '@' behind a sentinel
        # character before RedCloth ever sees it, regardless of whether it's
        # sitting inside a Textile '@...@' span at all. RedCloth then never
        # sees more than one '@' in a row, so it decides on its own
        # (correctly) whether to render <code>, leave it literal in a `bc.`
        # block, or leave it literal with inline code disabled (comments) --
        # we don't need to special-case any of that. We just swap the
        # sentinel back for '@' once RedCloth is done.
        def protect_email_inline_code(text)
          url_ranges = text.to_enum(:scan, BARE_URL).map { Regexp.last_match.begin(0)...Regexp.last_match.end(0) }

          text.gsub(EMAIL_PATTERN) do
            match = Regexp.last_match
            next match[0] if url_ranges.any? { |range| range.cover?(match.begin(0)) }

            match[0].sub('@', SENTINEL_CHAR)
          end
        end
      end
    end
  end
end
