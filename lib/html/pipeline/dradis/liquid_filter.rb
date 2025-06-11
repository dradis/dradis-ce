module HTML
  class Pipeline
    module Dradis
      class LiquidFilter < TextFilter
        LIQUID_FILTER_PATTERNS = [
          /#{Liquid::TagStart}+.*#{Liquid::FilterSeparator}+.*#{Liquid::TagEnd}+/,
          /#{Liquid::VariableStart}+.*#{Liquid::FilterSeparator}+.*#{Liquid::VariableEnd}+/
        ].freeze

        def call
          @text = HTML::IgnoreLiquidInTextileBlockCodes.call(@text)

          assigns = context.fetch(:liquid_assigns, {})

          options = {
            filters: [],
            strict_filters: true,
            strict_variables: true
          }

          Liquid::Template.parse(@text).render(assigns, options)
        rescue Liquid::SyntaxError
          @text
        end
      end
    end
  end
end
