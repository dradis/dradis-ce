begin
  require "redcloth"
rescue LoadError => _
  raise HTML::Pipeline::MissingDependencyError, "Missing dependency 'RedCloth' for TextileFilter. See README.md for details."
end

module HTML
  class Pipeline
    # HTML Filter that converts Textile text into HTML and converts into a
    # DocumentFragment. This is different from most filters in that it can take a
    # non-HTML as input. It must be used as the first filter in a pipeline.
    #
    # Context options:
    #   :autolink => false    Disable autolinking URLs
    #
    # This filter does not write any additional information to the context hash.
    #
    # NOTE This filter is provided for really old comments only. It probably
    # shouldn't be used for anything new.
    class DradisTextileFilter < TextFilter

      # Convert Textile to HTML and convert into a DocumentFragment. We need to
      # enclose everything in a root element.
      #
      # See:
      #   https://github.com/jch/html-pipeline#1-why-doesnt-my-pipeline-work-when-theres-no-root-element-in-the-document
      def call
        '<div>' +
        RedCloth.new(@text, [:filter_html, :no_span_caps]).to_html +
        '</div>'
      end
    end
  end
end