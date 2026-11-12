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

    it 'preserves Rust attributes and the content after them' do
      source = <<~HEREDOC
        #[Output]#
        bc.. #[cfg(windows)]
        Lorem ipsum dolor sit amet.

        #[Test]#
        Lorem ipsum dolor sit amet.
      HEREDOC

      result = [['Output', "bc.. #[cfg(windows)]\nLorem ipsum dolor sit amet."], ['Test', 'Lorem ipsum dolor sit amet.']]
      expect(described_class.source_to_fields_array(source)).to eq(result)
    end

    it 'preserves Rust attributes before the first field header' do
      source = "#[cfg(windows)]\nfn main() {}\n\n#[Title]#\nX"

      result = [['', "#[cfg(windows)]\nfn main() {}"], ['Title', 'X']]
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
