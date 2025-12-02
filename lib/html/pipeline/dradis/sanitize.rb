module HTML
  class Pipeline
    module Dradis
      class Sanitize
        # SEE: https://github.com/gjtorikian/html-pipeline/blob/v2.14.0/lib/html/pipeline/sanitization_filter.rb
        original_list = HTML::Pipeline::SanitizationFilter::WHITELIST

        ALLOWLIST = original_list.merge(
          attributes: original_list[:attributes].merge(
            # Allow style attribute
            all: original_list[:attributes][:all] + ['style']
          ).freeze,

          # Allow text-align property
          css: {
            properties: %w[ text-align border width height ]
          }.freeze
        )
      end
    end
  end
end
