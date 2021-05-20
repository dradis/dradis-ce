module HTML
  class Pipeline
    module Dradis
      class LiquidFilter < TextFilter
        def call
          assigns = context.fetch(:liquid_assigns, {})

          options = {
            filters: [],
            strict_filters: true,
            strict_variables: true
          }

          Liquid::Template.parse(@text).render(assigns, options)
        end
      end
    end
  end
end
