module HTML
  class IgnoreLiquidInTextileBlockCodes
    BLOCK_CODE_TYPES = ['bc. ', 'bc.. '].freeze
    BLOCK_PARAGRAPH_TYPES = (
      ['bq. ', 'bq.. ', 'h5. ', 'p. '] + BLOCK_CODE_TYPES
    ).freeze

    class << self
      def call(text)
        @lines = text.lines
        # Initialize a flag to identify block codes in the loop,
        # possible values are "bc. ", "bc.. ", nil
        current_block_code_type = nil
        output = []

        @lines.each_with_index do |line, index|
          BLOCK_CODE_TYPES.each do |block_code_type|
            if line.start_with?(block_code_type)
              current_block_code_type = block_code_type
            end
          end

          # If the flag is set previously, check if we can set it to nil
          if current_block_code_type
            if can_close_block_code?(
              block_code_type: current_block_code_type,
              line: line,
              index: index
            )
              current_block_code_type = nil
            end
          end

          # If the flag is still present, ignore liquid
          if current_block_code_type
            output << "{% raw %}#{line.chomp}{% endraw %}\n"
          else
            output << line
          end
        end
        output.join
      end

      def can_close_block_code?(block_code_type:, index:, line:)
        if block_code_type == BLOCK_CODE_TYPES[0]
          can_close_single_paragraph_block_code?(line)
        else
          can_close_multi_paragraph_block_code?(index: index, line: line)
        end
      end

      # "bc.." is closed if it contains a blank line after it
      # and the next line after the blank line is a block paragraph
      # ("bc.", "bc..", "bq.", "bq..", "h5.", "p.")

      # Example:
      #
      # bc.. hello
      # world
      # <-- still open here
      #
      # I'm still in the block
      #
      # p. My new paragraph <-- closed here because this line starts with "p." and the next line is a blank line.
      #
      def can_close_multi_paragraph_block_code?(index:, line:)
        next_index = index + 1
        next_line = @lines[next_index]

        line.chomp.blank? &&
          next_line &&
          (next_line.start_with?(*BLOCK_PARAGRAPH_TYPES) || next_line.match(FieldParser::FIELDS_REGEX))
      end

      # "bc." is closed if it contains a blank line after it.

      # Example:
      #
      # bc. hello
      # world <-- still open here because it isn't a blank line
      #       <-- closed here because it is a blank line
      # #[Description]#
      #
      def can_close_single_paragraph_block_code?(line)
        line.chomp.blank?
      end
    end
  end
end
