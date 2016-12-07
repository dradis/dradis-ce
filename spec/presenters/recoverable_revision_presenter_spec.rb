require 'spec_helper'

RSpec.describe RecoverableRevisionPresenter do
  describe '#title' do
    include ActionView::Helpers::TagHelper

    class FakeView
      include ActionView::Helpers::TextHelper
    end

    def revision_title_tag(text)
      content_tag :span, text, class: 'item-content'
    end

    def presenter_for(revision)
      described_class.new(revision, FakeView.new)
    end

    it 'returns the correct title for issues' do
      issue = create(:issue, text: "#[Title]#\nMy issue")
      issue.destroy
      revision = RecoverableRevision.new(issue.versions.last)

      presenter = presenter_for(revision)
      expect(presenter.send(:title)).to eq revision_title_tag("My issue")
    end

    it 'returns the correct title for notes' do
      note = create(:note, text: "#[Title]#\nMy note")
      note.destroy
      revision = RecoverableRevision.new(note.versions.last)

      presenter = presenter_for(revision)
      expect(presenter.send(:title)).to eq revision_title_tag('My note')
    end
  end
end
