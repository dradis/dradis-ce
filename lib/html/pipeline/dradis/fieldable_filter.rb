module HTML
  class Pipeline
    module Dradis
      # HTML Filter that converts Dradis-style field syntax into Textile headers.
      #
      # Context options:
      #   n/a
      #
      # This filter does not write any additional information to the context hash.
      class FieldableFilter < TextFilter
        # Convert the #[Field]# syntax into h4. headers
        def call
          output = @text.dup

          Hash[ *@text.scan(FieldParser::FIELDS_REGEX).flatten.collect{ |str| str.strip } ].keys.each do |field|
            output.gsub!(/#\[#{Regexp.escape(field)}\]#[\r|\n]/, "h5. #{field}\n\n")
          end

          output
        end
      end
    end
  end
end
