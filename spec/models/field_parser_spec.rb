require 'rails_helper'

describe FieldParser do
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
