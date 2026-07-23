class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  before_validation :scrub_invalid_text_column_encoding

  private

  # Pasted or imported content can contain invalid UTF-8 byte sequences.
  # Scrub every :text column before validation, so it never reaches the DB.
  def scrub_invalid_text_column_encoding
    self.class.columns_hash.each_value do |column|
      next unless column.type == :text

      value = self[column.name]
      self[column.name] = value.scrub if value.is_a?(String)
    end
  end
end
