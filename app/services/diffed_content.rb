class DiffedContent
  EXCLUDED_FIELDS = %w(id plugin plugin_id AddonTags)

  attr_reader :source, :target

  def initialize(source, target)
    @source = source
    @target = target

    normalize_content(@source)
    normalize_content(@target)
  end

  def content_diff
    diff_by_word(source.content, target.content)
  end

  # Lists the fields that have changed between the source and the target and
  # saves the diffed content for each field.
  #
  # Returns a hash with the following structure:
  # { field: { source: <diffed_source_field>, target: <diffed_target_field> } }
  def unsynced_fields
    @unsynced_fields ||=
      begin
        fields = @source.fields.except(*EXCLUDED_FIELDS).keys |
          @target.fields.except(*EXCLUDED_FIELDS).keys

        fields.filter_map do |field|
          source_value = source.fields[field] || ''
          target_value = target.fields[field] || ''

          if source_value != target_value
            [field, diff_by_word(source_value, target_value)]
          end
        end.to_h
      end
  end

  def changed?
    source.updated_at != target.updated_at &&
      source.content != target.content
  end

  def content_for_update(field_params = nil)
    if field_params
      {
        source: content_with_updated_field_from_target(field: field_params, source: @target.reload, target: @source.reload),
        target: content_with_updated_field_from_target(field: field_params, source: @source.reload, target: @target.reload)
      }
    else
      { source: @target.content, target: @source.content }
    end
  end

  private

  # Given a target record, update its field depending on the following cases:
  # 1) If the source record has the existing field:
  #   1.1) If the target record also has the existing field, update the value
  #     with the value from the source record
  #   1.2) If the target record does not have the field, insert the field
  #     at the same index where the field is present in the source record
  # 2) If the source record is missing the field, delete the field in the
  #   target record
  def content_with_updated_field_from_target(field:, source:, target:)
    source_fields = source.fields.keys
    source_index = source_fields.excluding(*EXCLUDED_FIELDS).index(field)

    # Case 1)
    if source_fields.include?(field)
      # Case 1.1)
      if target.fields.keys.include?(field)
        target.set_field(field, source.fields[field])
      # Case 1.2)
      else
        updated_fields = target.fields.to_a.insert(source_index, [field, source.fields[field]])
        FieldParser.fields_hash_to_source(updated_fields.compact)
      end
    # Case 2)
    else
      target.delete_field(field)
    end
  end

  def diff_by_word(source_content, target_content)
    Differ.format = :html
    differ_result = Differ.diff_by_word(source_content, target_content)

    output = highlighted_string(differ_result)

    { source: output[1], target: output[0] }
  end

  def normalize_content(record)
    fields = record.fields.except(*EXCLUDED_FIELDS)

    record.content =
      fields.map do |field, value|
        "#[#{field}]#\n#{value.gsub("\r",'')}\n"
      end.join("\n")
  end

  def highlighted_string(differ_result)
    [:delete, :insert].map do |highlight_type|
      result_str = differ_result.dup.to_s

      case highlight_type
      when :delete
        result_str.gsub!(/<del class="differ">(.*?)<\/del>/m, '<mark>\1</mark>')
        result_str.gsub!(/<ins class="differ">(.*?)<\/ins>/m, '')
      when :insert
        result_str.gsub!(/<ins class="differ">(.*?)<\/ins>/m, '<mark>\1</mark>')
        result_str.gsub!(/<del class="differ">(.*?)<\/del>/m, '')
      end

      result_str.html_safe
    end
  end
end
