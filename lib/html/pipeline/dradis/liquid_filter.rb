module HTML
  class Pipeline
    module Dradis
      class LiquidFilter < TextFilter
        REGEX = /\$\$\[\[(.+?)\]\]\$\$/

        def call
          hide_code_highlight_syntax

          assigns = context.fetch(:liquid_assigns, {})

          options = {
            filters: [],
            strict_filters: true,
            strict_variables: true
          }

          Liquid::Template.parse(@text).render(assigns, options)

          restore_code_highlight_syntax
        end

        private
        def hide_code_highlight_syntax
          @text.gsub(CodeHighlightFilter::REGEX) do |match|
            %|$$[[#{$1}]]$$|
          end
        end
        def restore_code_highlight_syntax
          @text.gsub(REGEX) do |match|
            %|$${{#{$1}}}|
          end
          @text
        end
      end
    end
  end
end
