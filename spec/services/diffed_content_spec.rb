require 'rails_helper'

describe DiffedContent do
  let(:issue1) { create(:issue, text: "#[Title]#\nIssue1\n") }
  let(:issue2) { create(:issue, text: "#[Title]#\nIssue2\n") }

  subject { described_class.new(issue1, issue2) }

  describe '#content_diff' do
    it 'returns the diff' do
      expect(subject.content_diff).to eq({
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

  describe '#unsynced_fields' do
    it 'returns the fields that have changed between the source and the target' do
      expect(subject.unsynced_fields).to eq({
        'Title' => {
          source: '<mark>Issue1</mark>',
          target: '<mark>Issue2</mark>'
        }
      })
    end
  end

  describe '#content_for_update' do
    context 'field_params is present' do
      context 'the field is present in both the source and target' do
        it 'returns the updated content' do
          expect(subject.content_for_update('Title')).to eq({
            :source => "#[Title]#\n#{issue2.reload.title}",
            :target => "#[Title]#\n#{issue1.reload.title}"
          })
        end
      end

      context 'the field is not present in the source' do
        before do
          issue2.update(content: "#[Title]#\nIssue2\n\n#[Description]#\nTest Description\n")
        end

        it 'returns the updated content' do
          expect(subject.content_for_update('Description')).to eq({
            :source => "#[Title]#\n#{issue1.reload.title}\n\n#[Description]#\nTest Description",
            :target => "#[Title]#\n#{issue2.reload.title}"
          })
        end
      end

      context 'the field is blank in the issue' do
        before do
          issue1.update(content: "#[Title]#\nIssue1\n\n#[Description]#\n\n")
          issue2.update(content: "#[Title]#\nIssue2\n\n#[Description]#\nTest Description\n")
        end

        it 'returns the updated content' do
          expect(subject.content_for_update('Description')).to eq({
            :source => "#[Title]#\n#{issue1.reload.title}\n\n#[Description]#\nTest Description",
            :target => "#[Title]#\n#{issue2.reload.title}\n\n#[Description]#\n"
          })
        end
      end

      context 'the field is found on an index not present in the issue' do
        before do
          issue2.update(content: "#[Title]#\nIssue2\n\n#[Description]#\nTest Description\n\n#[Mitigation]#\nTest Mitigation\n")
        end

        it 'returns the updated content' do
          expect(subject.content_for_update('Mitigation')).to eq({
            :source => "#[Title]#\n#{issue1.reload.title}\n\n#[Mitigation]#\nTest Mitigation",
            :target => "#[Title]#\n#{issue2.reload.title}\n\n#[Description]#\nTest Description"
          })
        end
      end
    end

    context 'field_params is not present' do
      it 'returns the issue and entry content' do
        expect(subject.content_for_update(nil)).to eq({
          :source => "#[Title]#\n#{issue2.reload.title}\n",
          :target => "#[Title]#\n#{issue1.reload.title}\n"
        })
      end
    end
  end
end
