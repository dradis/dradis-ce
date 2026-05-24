module HasFields
  extend ActiveSupport::Concern

  # This method can be overridden by classes including the module to add
  # custom fields to the collection that would normally be returned by
  # parsing the text blob stored in the property.
  def local_fields
    {}
  end

  # Extract a Title file if one exists.
  def title
    fields.fetch(
      'Title',
      '(No #[Title]# field)'
    )
  end

  def title?
    fields['Title'].present?
  end

  private

  def update_container(container_field, updated_fields)
    self.send(
      :"#{container_field}=",
      FieldParser.fields_hash_to_source(updated_fields)
    )
  end

  module ClassMethods
    def dradis_has_fields_for(container_field)
      rendered_field = :"rendered_#{container_field}"

      # Always returns raw (unrendered) field values.
      define_method :raw_fields do
        if raw_content = self.send(container_field)
          local_fields.merge(FieldParser.source_to_fields(raw_content))
        else
          {}
        end
      end

      # Returns Liquid-rendered field values. If a rendered cache exists,
      # returns it directly. If not, renders lazily using the record's
      # project context, writes the result to the cache, and returns it.
      define_method :fields do
        @fields ||= if (cached = self.send(rendered_field)).present?
          local_fields.merge(FieldParser.source_to_fields(cached))
        else
          assigns = LiquidCachedAssigns.new(project: node.project)

          rendered = raw_fields.transform_values do |value|
            HTML::Pipeline::Dradis::LiquidFilter.call(value, liquid_assigns: assigns)
          rescue Liquid::Error
            value
          end

          update_column(rendered_field, FieldParser.fields_hash_to_source(rendered))
          local_fields.merge(FieldParser.source_to_fields(self.send(rendered_field)))
        end
      end

      define_method :set_field do |field, value|
        updated_fields = raw_fields
        updated_fields[field] = value
        self.update_container(container_field, updated_fields)
      end

      define_method :delete_field do |field|
        updated_fields = raw_fields
        updated_fields.except!(field)
        self.update_container(container_field, updated_fields)
      end
    end
  end
end
