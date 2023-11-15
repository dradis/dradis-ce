module HTML
  class IgnoreLiquid
    class << self
      def call(text)
        @lines = text.lines
        # Initialize a flag to identify block codes in the loop,
        # possible values are "bc. ", "bc.. ", nil
        current_block_code_type = nil
        output = []

        @lines.each_with_index do |line, index|
          current_block_code_type = IgnoreLiquidInTextileBlockCodes.call(text, index, line, @lines)
          current_link_type = IgnoreLiquidInLinks.call(line)

          if current_block_code_type
            output << "{% raw %}#{line.chomp}{% endraw %}\n"
          elsif current_link_type
            output << "{% raw %}#{line.chomp}{% endraw %}\n"
          else
            output << line
          end
        end
        output.join
      end
    end
  end
end
