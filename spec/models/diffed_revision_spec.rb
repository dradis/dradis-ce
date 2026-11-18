require 'rails_helper'

RSpec.describe DiffedRevision do
  let(:record) { Issue.new(text: after) }
  let(:revision) do
    instance_double(PaperTrail::Version, event: 'update', next: nil,
                                         object: { 'text' => "Title\r\nBody\r\n" }.to_yaml)
  end

  subject(:diff) { described_class.new(revision, record).diff.format_as(:color) }

  context 'when only line endings change' do
    let(:after) { "Title\nBody\n" }

    it 'preserves line breaks without highlighting a change' do
      expect(diff).to eq(after)
    end
  end

  context 'when text and line endings change' do
    let(:after) { "Title\nUpdated\n" }

    it 'highlights the edit without carriage returns' do
      expect(diff).to include("\e[31mBody\e[0m", "\e[32mUpdated\e[0m")
      expect(diff).not_to include("\r")
    end
  end
end
