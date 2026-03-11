# Encapsulates the anchor attribute: a W3C Web Annotation-style text
# selector that records where in the commentable's content the inline
# thread was placed.
#
# The anchor is a JSON hash with keys:
#
#   type       - always "TextQuoteSelector"
#   exact      - the selected text (also exposed as #quoted_text)
#   prefix     - text immediately before the selection (for disambiguation)
#   suffix     - text immediately after the selection
#   field_name - the Dradis field (e.g. "Title", "Description") containing
#                the selection
#   position   - { start: Integer, end: Integer } character offsets within
#                the field's raw text (including #[FieldName]# markers)
#
# Positions arrive from the browser as strings and are coerced to integers
# during validation.
module InlineThread::Anchor
  extend ActiveSupport::Concern

  REQUIRED_ANCHOR_KEYS = %w[exact position prefix suffix type].freeze

  included do
    serialize :anchor, coder: JSON

    validates :anchor, presence: true
    validate :anchor_schema
  end

  def quoted_text
    anchor&.dig('exact')
  end

  private

  def anchor_schema
    return if anchor.blank?

    missing = REQUIRED_ANCHOR_KEYS - anchor.keys
    if missing.any?
      errors.add(:anchor, "missing required keys: #{missing.join(', ')}")
      return
    end

    return unless anchor['position'].is_a?(Hash)

    %w[start end].each do |key|
      val = anchor['position'][key]
      case val
      when Integer
        next
      when /\A\d+\z/
        anchor['position'][key] = val.to_i
      else
        errors.add(:anchor, 'position must have integer start and end')
        return
      end
    end
  end
end
