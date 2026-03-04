# Locates a user's text selection within the raw Dradis field content and
# returns a TextQuoteSelector anchor hash with position metadata.
#
# Uses FieldParser to split content into per-field sections, then searches
# each field value for the selection. Two normalisations are applied to
# bridge the gap between raw content and the rendered text the user selects:
#
# - Typography: RedCloth converts straight quotes to curly quotes. Since
#   these are 1:1 character substitutions, normalising both sides preserves
#   raw byte positions.
# - Whitespace: paragraph boundaries in raw (\n\n) and browser selections
#   (\n) can differ. A flexible regex is used as a last resort.
#
# Note: selections that cross Textile markup (links, code spans, etc.) may
# not resolve. Reverse-mapping rendered HTML positions to raw positions would
# require a full position-mapped render pass, which is out of scope here.
#
# Usage:
#   result = InlineThreadAnchorFinder.new(raw_content, selected_text).call
#   # => { type: 'TextQuoteSelector', exact: '...', prefix: '...', ... }
#   # => nil if the selection cannot be located
class InlineThreadAnchorFinder
  def initialize(raw_content, selected_text)
    @raw      = raw_content.to_s.gsub("\r\n", "\n")
    @selected = selected_text.to_s.gsub("\r\n", "\n").strip
  end

  def call
    return nil if @selected.empty?

    each_field do |field_name, value, value_start|
      result = find_in(value, value_start, field_name)
      return result if result
    end

    nil
  end

  private

  def each_field
    headerless = FieldParser.parse_fields_without_headers(@raw)
    if headerless && !headerless.empty?
      idx = @raw.index(headerless)
      yield nil, headerless, idx if idx
    end

    @raw.scan(FieldParser::FIELDS_REGEX) do
      m = Regexp.last_match
      yield m[1].strip, m[2], m.begin(2)
    end
  end

  def find_in(value, raw_offset, field_name)
    normalized_value    = normalize_typography(value)
    normalized_selected = normalize_typography(@selected)

    idx = value.index(@selected)
    return build_result(raw_offset + idx, raw_offset + idx + @selected.length, field_name) if idx

    idx = normalized_value.index(normalized_selected)
    return build_result(raw_offset + idx, raw_offset + idx + @selected.length, field_name) if idx

    idx, length = flexible_match(normalized_value, normalized_selected)
    build_result(raw_offset + idx, raw_offset + idx + length, field_name) if idx
  end

  def flexible_match(text, search)
    escaped = Regexp.escape(search)
    pattern = escaped.gsub(/[ \t]*\n[ \t\n]*/, '[ \t]*\n[ \t\n]*')
    m = Regexp.new(pattern).match(text)
    m ? [m.begin(0), m[0].length] : nil
  end

  def build_result(raw_start, raw_end, field_name)
    {
      type:       'TextQuoteSelector',
      exact:      @selected,
      prefix:     @raw[[0, raw_start - 30].max...raw_start],
      suffix:     @raw[raw_end...[@raw.length, raw_end + 30].min],
      position:   { start: raw_start, end: raw_end },
      field_name: field_name
    }
  end

  def normalize_typography(text)
    text
      .tr("\u2018\u2019", "''")
      .tr("\u201C\u201D", '""')
  end
end
