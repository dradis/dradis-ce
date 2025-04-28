require 'rails_helper'

describe 'Escaping string from Drops' do
  let(:issue) { create(:issue, text: "#[Title]#\n<h1>test output</h1>\n") }

  describe BaseDrop do
    it 'automatically escapes the string outputs' do
      class TestDrop < BaseDrop
        delegate :title, to: :@record
      end

      drop = TestDrop.new(issue)

      expect(drop.title).to eq('&lt;h1&gt;test output&lt;/h1&gt;')
    end
  end

  describe EscapedFields do
    it 'automatically escapes the field values' do
      class TestDrop < BaseDrop
        include EscapedFields
      end

      drop = TestDrop.new(issue)
      expect(drop.fields['Title']).to eq('&lt;h1&gt;test output&lt;/h1&gt;')
    end
  end
end
