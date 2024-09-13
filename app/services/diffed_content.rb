class DiffedContent
  attr_reader :source, :target

  def initialize(source, target)
    @source = source
    @target = target

    normalize_content(@source)
    normalize_content(@target)
  end

  def diff
    Differ.format = :html
    differ_result = Differ.diff_by_word(source.content, target.content)

    output = highlighted_string(differ_result)

    { source: output[1], target: output[0] }
  end

  def changed?
    source.updated_at != target.updated_at &&
      source.content != target.content
  end

  private

  def normalize_content(record)
    fields = record.fields.except('id', 'plugin', 'plugin_id')

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
