class MarkupFields

    # Field regex with capturing groups for name and description
    FIELD_REGEX = /(?<=#\[)([\w\.]+?)(?=\]#).*?(?<=\]#)(.+?)(?=#\[|\z|\n)/i

    Field = Struct.new(:name, :value)

    def initialize(markup)
        @markup = markup.to_s
    end

    def fields
        @fields ||= parse
    end

    private

    def markup
        @markup
    end

    def parse
        markup.scan(FIELD_REGEX)
            .map { |match| Field.new(match[0], match[1]) }
    end
end
