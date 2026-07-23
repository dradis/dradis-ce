module ScrubsInvalidEncoding
  extend ActiveSupport::Concern

  module ClassMethods
    # Pasted or imported content can contain invalid UTF-8 byte sequences.
    # Scrub the given attributes before validation, so they never reach the DB.
    def scrub_invalid_encoding_for(*attributes)
      before_validation do
        attributes.each do |attribute|
          value = public_send(attribute)
          public_send(:"#{attribute}=", value.scrub) if value.is_a?(String)
        end
      end
    end
  end
end
