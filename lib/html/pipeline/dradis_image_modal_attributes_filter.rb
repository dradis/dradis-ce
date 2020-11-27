module HTML
  class Pipeline
    class DradisImageModalAttributesFilter < Filter
      def call
        doc.search(":not(span.gravatar)/img").each do |image|
          image['data-target'] = '[data-behavior~=image-modal]'
          image['data-toggle'] = 'modal'
        end

        doc
      end
    end
  end
end
