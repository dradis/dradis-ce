require 'rails_helper'

describe DiffedContent do
  let(:issue1) { create(:issue, text: "#[Title]#\nIssue1\n") }
  let(:issue2) { create(:issue, text: "#[Title]#\nIssue2\n") }

  subject { described_class.new(issue1, issue2) }

  describe '#diff' do
    it 'returns the diff' do
      expect(subject.diff).to eq({
        source: "#[Title]#\n<mark>Issue1</mark>\n",
        target: "#[Title]#\n<mark>Issue2</mark>\n"
      })
    end
  end

  describe '#changed?' do
    context 'source and target does not match' do
      it 'returns true' do
        issue1.update text: 'test', updated_at: Time.now + 1.day
        expect(subject.changed?).to eq true
      end
    end

    context 'source and target matches' do
      it 'returns false' do
        issue1.update text: issue2.content
        expect(subject.changed?).to eq false
      end
    end
  end
end
