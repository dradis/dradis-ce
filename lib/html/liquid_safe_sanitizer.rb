module HTML
  class LiquidSafeSanitizer
    LIQUID_PLACEHOLDER_FORMAT = "DRADISSAFE_#{SecureRandom.hex(8)}_%d"
    LIQUID_TAGS_REGEX = /\{%.*?%\}|\{\{.*?\}\}/m.freeze

    class << self
      def call(str)
        stash = []
        text = str.gsub(LIQUID_TAGS_REGEX) do |match|
          stash << match
          format(LIQUID_PLACEHOLDER_FORMAT, stash.size - 1)
        end

        sanitized = HTML::Pipeline::SanitizationFilter.call(text).to_s

        stash.each_with_index { |tag, i| sanitized.sub!(format(LIQUID_PLACEHOLDER_FORMAT, i), tag) }

        sanitized
      end
    end
  end
end
