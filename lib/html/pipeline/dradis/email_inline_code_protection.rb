module HTML
  class Pipeline
    module Dradis
      # Shared RedCloth-parsing workaround used by both the CE TextileFilter
      # (HTML output) and Pro's Word export TextileFilter (OOXML output).
      #
      # RedCloth requires the closing '@' of an inline code span to be
      # immediately followed by a non-word character, and matches the
      # first '@' satisfying that rule as the closer. An email address
      # inside a span (e.g. '@admin@starfleet.com@') has an embedded '@'
      # that RedCloth may treat as (part of) the closer, so it either
      # abandons the whole span or mis-parses it (e.g. a dotted local
      # part like '@first.last@starfleet.com@' gets truncated). We avoid
      # this entirely by hiding, behind a sentinel character, the inner
      # '@' of any email address that's itself wrapped in a '@...@' span
      # before RedCloth ever sees it. RedCloth then never sees more than
      # one '@' in a row within the span, so it decides on its own
      # (correctly) whether to render inline code, leave it literal in a
      # `bc.` block, or leave it literal with inline code disabled -- we
      # don't need to special-case any of that. Callers just swap the
      # sentinel back for '@' once RedCloth (and any formatter) is done.
      module EmailInlineCodeProtection
        # The URI::MailTo::EMAIL_REGEXP uses anchors: \A/\z that we don't need.
        EMAIL_INNER_PATTERN = URI::MailTo::EMAIL_REGEXP.source.delete_prefix('\A').delete_suffix('\z')

        # Only match emails sandwiched between a literal '@' on each side --
        # i.e. an actual Textile '@...@' inline-code span -- rather than every
        # email address anywhere in the text. The boundary '@'s are matched
        # via lookaround so they're left in place for RedCloth to pair up as
        # the span's own opening/closing markers.
        EMAIL_PATTERN = /(?<=@)#{EMAIL_INNER_PATTERN}(?=@)/

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

        module_function

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
