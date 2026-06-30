module HTML
  class LiquidSafeSanitizer
    LIQUID_PLACEHOLDER_FORMAT = "DRADISSAFE_#{SecureRandom.hex(8)}_%d"
    LIQUID_TAGS_REGEX = /\{%.*?%\}|\{\{.*?\}\}/m.freeze

    # Note: HTML inside Liquid delimiters (e.g. {% assign x = "<script>..." %}) is stashed
    # verbatim and not sanitized at this layer. This is fine at the moment since the content reaches the
    # browser only via the full rendering pipeline (ApplicationHelper#markup), which runs
    # SanitizationFilter again after Liquid evaluation. Liquid's default auto-escaping also applies to {{ }} output.
    # BUT do not add raw-output rendering paths without accounting for this otherwise you will introduce XSS vulnerabilities.
    class << self
      def call(str)
        stash = []
        text = str.gsub(LIQUID_TAGS_REGEX) do |match|
          stash << match
          format(LIQUID_PLACEHOLDER_FORMAT, stash.size - 1)
        end

        sanitized = HTML::Pipeline::SanitizationFilter.call(text).to_s

        # Use block form of sub! so Ruby treats the replacement as a literal string
        # rather than interpolating backslash sequences (e.g. \1, \&) from the tag content.
        stash.each_with_index do |tag, i|
          sanitized.sub!(format(LIQUID_PLACEHOLDER_FORMAT, i)) { tag }
        end

        sanitized
      end
    end
  end
end
