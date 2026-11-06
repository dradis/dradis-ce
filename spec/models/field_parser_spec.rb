require 'rails_helper'

describe FieldParser do
  describe '.source_to_fields' do
    it 'preserves inline field delimiters inside code blocks with CRLF line endings' do
      output = <<~HEREDOC.strip.gsub("\n", "\r\n")
        bc.. I am a bunch of output
        Some of it contains #[ but it's wrapped in a code block
        Here, let's close the field ]#
        Keep going with code
      HEREDOC
      source = "#[Output]#\r\n#{output}\r\n\r\n#[Notes]#\r\nMy notes"

      result = { 'Output' => output, 'Notes' => 'My notes' }
      expect(described_class.source_to_fields(source)).to eq(result)
    end
  end

  describe '.source_to_fields_array' do
    it 'converts the source to an array of field name/value pairs' do
      source = <<~HEREDOC
        #[Title]#
        Issue 1

        #[Description]#
        My description
      HEREDOC

      result = [['Title', 'Issue 1'], ['Description', 'My description']]
      expect(described_class.source_to_fields_array(source)).to eq(result)
    end

    it 'can contain duplicated field names' do
      source = <<~HEREDOC
        #[Title]#
        Issue 1

        #[Description]#
        My description

        #[Description]#
        My description 2
      HEREDOC

      result = [['Title', 'Issue 1'], ['Description', 'My description'], ['Description', 'My description 2']]
      expect(described_class.source_to_fields_array(source)).to eq(result)
    end

    it 'preserves inline field delimiters in headerless text' do
      headerless = 'Text containing an inline #[x]# marker'
      source = "#{headerless}\n\n#[Field]#\nMy field"

      result = [['', headerless], ['Field', 'My field']]
      expect(described_class.source_to_fields_array(source)).to eq(result)
    end

    it 'supports text without field names' do
      source = <<~HEREDOC
        Issue 1

        #[Description]#
        My description
      HEREDOC

      result = [['', 'Issue 1'], ['Description', 'My description']]
      expect(described_class.source_to_fields_array(source)).to eq(result)
    end
  end
end
