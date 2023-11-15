module HTML
  class IgnoreLiquid
    class << self
      def call(text)
        # first escape code blocks, then escape links
        escaped_code_blocks = IgnoreLiquidInTextileBlockCodes.call(text)
        IgnoreLiquidInLinks.call(escaped_code_blocks)
      end
    end
  end
end
