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
    # Method for models to define which attribute is to be converted to fields.
    #
    # If the given field format does not conform to the expected syntax, an
    # empty Hash is returned.
    def dradis_has_fields_for(container_field)
      define_method :raw_fields do
        if raw_content = self.send(container_field)
          local_fields.merge(FieldParser.source_to_fields(raw_content))
        else
          {}
        end
      end

      define_method :fields do
        raw = raw_fields
        return raw unless LiquidRenderContext.current
        return @_rendered_fields if @_rendered_fields

        # Guard against reentrancy: a Drop accessing this record's fields during
        # LiquidFilter evaluation would loop infinitely. While rendering is in progress, return raw values to break the cycle.
        # ensure is scoped to the begin block below, not the method — an ensure on
        # the method fires on all return paths and would clear the flag prematurely.
        return raw if @_rendering_fields

        @_rendering_fields = true
        begin
          @_rendered_fields = raw.transform_values { |v| LiquidRenderContext.render(v) }
        ensure
          @_rendering_fields = false
        end
        @_rendered_fields
      end

      # Setting fields using model.fields["field_name"] = "value" currently
      # doesn't work (the hash in local memory will change, but the underlying
      # attribute in the ActiveRecord model won't be affected). So the
      # following code won't do what you might expect:
      #
      #   evidence = Evidence.find(1)
      #   evidence.content = "#[Foo]#\nBar"
      #   evidence.fields["Foo"] = "Buzz"
      #   evidence.save!
      #   evidence.reload.content # => "#[Foo]#\nBar" # Oh noes! It hasn't changed
      #
      # So use set_field instead:
      #
      #   evidence.set_field "Foo", "Buzz"
      #
      define_method :set_field do |field, value|
        @_rendered_fields = nil
        updated_fields = raw_fields
        updated_fields[field] = value
        self.update_container(container_field, updated_fields)
      end

      # Completely removes the field (field header and value) from the content
      define_method :delete_field do |field|
        @_rendered_fields = nil
        updated_fields = raw_fields
        updated_fields.except!(field)
        self.update_container(container_field, updated_fields)
      end
    end
  end
end
