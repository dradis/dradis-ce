module HTML
  class Pipeline
    module Dradis
      class LiquidFilter < TextFilter
        def call
          @text = HTML::IgnoreLiquid.call(@text)

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
