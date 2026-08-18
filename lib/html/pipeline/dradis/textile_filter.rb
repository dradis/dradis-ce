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
        # this entirely by hiding only the email's inner '@' behind a
        # sentinel character before RedCloth ever sees it, leaving the
        # span's opening and closing '@' untouched. RedCloth then parses an
        # ordinary single-embedded-'@' span, so it decides on its own
        # (correctly) whether to render <code>, leave it literal in a `bc.`
        # block, or leave it literal with inline code disabled (comments) --
        # we don't need to special-case any of that. We just swap the
        # sentinel back for '@' once RedCloth is done.
        EMAIL_INLINE_CODE_PATTERN = /@([\w+\-.]+)@([\w-]+(?:\.[\w-]+)+)@/

        # U+FDD0 is a Unicode noncharacter: the standard guarantees it can
        # never legitimately appear in interchanged text, so it's safe to
        # use as a marker with a plain global find/replace -- no lookup
        # table, no risk of colliding with real content. On the vanishingly
        # unlikely chance input already contains this exact codepoint, we
        # degrade gracefully (it's rendered back as a literal '@') rather
        # than raising.
        EMAIL_AT_SENTINEL = "\uFDD0"

        # A contiguous non-whitespace run containing '://' is a URL, whether
        # bare or the target of Textile link syntax ("text":URL). RedCloth
        # already handles an embedded '@...@' correctly in both cases on its
        # own, so we leave those alone rather than protecting them: bare
        # URLs stay one unbroken string for AutolinkFilter to link as a
        # whole, instead of being split into link/code fragments by an
        # email we protected and later restored as <code>.
        BARE_URL_PATTERN = %r{\S*://\S+}

        def call
          parser = RedCloth.new(protect_email_inline_code(@text), [:filter_html, :no_span_caps])

          doc = if context[:no_inline_code]
            parser.to(HTML::NoInlineCodeTextileFormatter)
          else
            parser.to_html
          end

          "<div>#{restore_email_inline_code(doc)}</div>"
        end

        private

        def protect_email_inline_code(text)
          url_ranges = text.to_enum(:scan, BARE_URL_PATTERN).map { Regexp.last_match.begin(0)...Regexp.last_match.end(0) }

          text.gsub(EMAIL_INLINE_CODE_PATTERN) do
            match = Regexp.last_match
            next match[0] if url_ranges.any? { |range| range.cover?(match.begin(0)) }

            "@#{match[1]}#{EMAIL_AT_SENTINEL}#{match[2]}@"
          end
        end

        def restore_email_inline_code(html)
          html.gsub(EMAIL_AT_SENTINEL, '@')
        end
      end
    end
  end
end
