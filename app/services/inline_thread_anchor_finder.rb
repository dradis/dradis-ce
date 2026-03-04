# Locates a user's text selection within the raw Dradis field content and
# returns a TextQuoteSelector anchor hash with position metadata.
#
# The raw content uses Dradis field syntax (#[Field]#) and Textile markup,
# while the user selects from rendered HTML. This service normalises the
# differences so the selection can be found in the raw text:
#
# - #[Field]# markers are stripped from the search space (they are invisible
#   in the rendered output) while maintaining a position map back to raw.
# - Textile link syntax ("text":url) and code spans (@code@) are similarly
#   stripped from the search space.
# - Typographic characters introduced by Textile's smart-quotes filter
#   (curly quotes, em/en dashes) are normalised before comparison.
# - Whitespace sequences are matched flexibly to handle paragraph boundary
#   differences between raw (\n\n) and browser selection (\n).
#
# Usage:
#   result = InlineThreadAnchorFinder.new(raw_content, selected_text).call
#   # => { type: 'TextQuoteSelector', exact: '...', prefix: '...', ... }
#   # => nil if not found
class InlineThreadAnchorFinder
  FIELD_MARKER_REGEX = /#\[([^\]]*)\]#/
  TEXTILE_LINK_REGEX = /"([^"\n]+)":\S+/
  CODE_SPAN_REGEX    = /@([^@\n]+)@/

  def initialize(raw_content, selected_text)
    @raw      = raw_content.to_s.gsub("\r\n", "\n")
    @selected = selected_text.to_s.gsub("\r\n", "\n").strip
  end

  def call
    return nil if @selected.empty?

    try_exact_in_raw(@selected) ||
      try_in_stripped(@selected) ||
      try_in_stripped(normalize_typography(@selected)) ||
      try_flexible_in_stripped(normalize_typography(@selected))
  end

  private

  def try_exact_in_raw(search)
    idx = @raw.index(search)
    return build_result(idx, idx + search.length) if idx

    nil
  end

  def try_in_stripped(search)
    stripped, map = stripped_map
    idx = stripped.index(search)
    return map_to_result(idx, idx + search.length, map) if idx

    nil
  end

  def try_flexible_in_stripped(search)
    stripped, map = stripped_map
    normalized_stripped = normalize_typography(stripped)

    escaped = Regexp.escape(search)
    flexible_pattern = escaped.gsub(/[ \t]*\n[ \t\n]*/, '[ \t]*\n[ \t\n]*')
    m = Regexp.new(flexible_pattern).match(normalized_stripped)
    return nil unless m

    map_to_result(m.begin(0), m.end(0), map)
  end

  def map_to_result(stripped_start, stripped_end, map)
    return nil if stripped_end > map.length

    raw_start = map[stripped_start]
    raw_end   = map[stripped_end - 1] + 1
    build_result(raw_start, raw_end)
  end

  def build_result(raw_start, raw_end)
    {
      type:       'TextQuoteSelector',
      exact:      @selected,
      prefix:     @raw[[0, raw_start - 30].max...raw_start],
      suffix:     @raw[raw_end...[@raw.length, raw_end + 30].min],
      position:   { start: raw_start, end: raw_end },
      field_name: find_field_name(raw_start)
    }
  end

  def stripped_map
    @stripped_map ||= build_stripped_map
  end

  def build_stripped_map
    replacements = collect_replacements
    stripped     = +''
    map          = []
    last_end     = 0

    replacements.each do |marker_start, marker_end, content, content_offset|
      last_end.upto(marker_start - 1) do |i|
        map << i
        stripped << @raw[i]
      end

      content.each_char.with_index do |char, j|
        map << (marker_start + content_offset + j)
        stripped << char
      end

      last_end = marker_end
    end

    last_end.upto(@raw.length - 1) do |i|
      map << i
      stripped << @raw[i]
    end

    [stripped, map]
  end

  def collect_replacements
    replacements = []

    [
      [FIELD_MARKER_REGEX, 2],  # skip #[
      [TEXTILE_LINK_REGEX, 1],  # skip opening "
      [CODE_SPAN_REGEX,    1]   # skip opening @
    ].each do |regex, offset|
      @raw.scan(regex) do |match|
        m = Regexp.last_match
        replacements << [m.begin(0), m.end(0), match[0], offset]
      end
    end

    # Sort by position; discard overlapping matches (first one wins)
    replacements.sort_by! { |r| r[0] }
    non_overlapping = []
    last_end = 0

    replacements.each do |r|
      next if r[0] < last_end

      non_overlapping << r
      last_end = r[1]
    end

    non_overlapping
  end

  def normalize_typography(text)
    text
      .tr("\u2018\u2019", "''")
      .tr("\u201C\u201D", '""')
      .gsub("\u2013", '--')
      .gsub("\u2014", '---')
  end

  def find_field_name(position)
    field_name = nil

    @raw.scan(/#\[(.+?)\]#/) do
      break if Regexp.last_match.begin(0) > position

      field_name = Regexp.last_match(1)
    end

    field_name
  end
end
