HTML::Pipeline.require_dependency('redcloth', 'RedCloth')

module HTML
  class Pipeline
    # HTML Filter that converts Textile text into HTML and converts into a
    # DocumentFragment.
    #
    # This filter does not write any additional information to the context hash.
    #
    # NOTE we use this instead of html-pipeline's own TextileFilter because
    # a) we want to pass the 'no_span_caps' option to RedCloth (otherwise
    #   things like URLs get messed up, see e.g. the specs).
    # b) the output needs to be wrapped in a <div> to make the pipeline work
    #    correctly, we can't add this <div> at an earlier point in the pipeline
    #    because then RedCloth can't parse the Textile correctly.
    class DradisTextileFilter < TextFilter
      def call
        parser = RedCloth.new(@text, [:filter_html, :no_span_caps])

        doc = if context[:no_inline_code]
          parser.to(HTML::NoInlineCodeTextileFormatter)
        else
          parser.to_html
        end

        "<div>#{doc}</div>"
      end
    end
  end
end
