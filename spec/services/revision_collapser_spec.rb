# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RevisionCollapser, versioning: true do
  let(:resource) { create(:issue) }
  let(:user_email) { 'adama@dradisframework.com' }

  describe '.collapse' do
    subject(:collapse_revisions) do
      described_class.collapse(resource: resource, user_email: user_email, event: RevisionTracking::REVISABLE_EVENTS[:autosave])
    end

    it 'changes nothing when no autosaves exist' do
      expect { collapse_revisions }.to change { resource.versions.count }.by(0)
    end

    context 'when there are 3 autosave revisions' do
      # Part of this context tests what happens when multiple auto saves exist
      # although we clean everytime a new one comes in so technically there
      # should never be more than 2.
      before do
        3.times do
          resource.tap { |r| r.paper_trail_event = RevisionTracking::REVISABLE_EVENTS[:autosave] }.touch
        end
      end

      it 'removes all but 1 autosave' do
        expect { collapse_revisions }.to change {
          resource.versions.where(event: RevisionTracking::REVISABLE_EVENTS[:autosave]).count
        }.by(-2)
      end

      it 'keeps the latest autosave' do
        last_save_id = PaperTrail::Version.last.id
        collapse_revisions
        expect(resource.versions.last.id).to be last_save_id
      end

      it 'removes all autosaves when the record is updated' do
        resource.touch(:updated_at)

        expect { collapse_revisions }.to change {
          resource.versions.where(event: RevisionTracking::REVISABLE_EVENTS[:autosave]).count
        }.by(-3)
      end
    end

    describe 'persisting original state' do
      it 'carrys original state forward over autosaves' do
        resource = create(:issue, text: 'ABC')
        resource.update(text: 'ABCD', paper_trail_event: RevisionTracking::REVISABLE_EVENTS[:autosave])
        resource.update(text: 'ABCDE', paper_trail_event: RevisionTracking::REVISABLE_EVENTS[:autosave])
        resource.update(text: 'ABCDEF', paper_trail_event: RevisionTracking::REVISABLE_EVENTS[:autosave])

        described_class.collapse(resource: resource, user_email: user_email)

        expect(resource.versions.last.reify.text).to eq('ABC')
      end

      it 'carrys original state forward over autosaves to final update' do
        resource = create(:issue, text: 'ABC')
        resource.update(text: 'ABCD', paper_trail_event: RevisionTracking::REVISABLE_EVENTS[:autosave])
        resource.update(text: 'ABCDE', paper_trail_event: RevisionTracking::REVISABLE_EVENTS[:autosave])
        resource.update(text: 'ABCDEF', paper_trail_event: RevisionTracking::REVISABLE_EVENTS[:autosave])
        resource.update(text: 'ABCDEF', paper_trail_event: RevisionTracking::REVISABLE_EVENTS[:update])

        described_class.collapse(resource: resource, user_email: user_email)

        expect(resource.versions.last.reify.text).to eq('ABC')
      end
    end

    context 'when the last revision is an update' do
      before do
        3.times do
          resource.tap { |r| r.paper_trail_event = RevisionTracking::REVISABLE_EVENTS[:autosave] }.touch
        end

        resource.touch
      end

      it 'removes all autosave revisions' do
        expect { collapse_revisions }.to change {
          resource.versions.where(event: RevisionTracking::REVISABLE_EVENTS[:autosave]).count
        }.by(-3)
      end

      it 'keeps the latest update revision' do
        last_save_id = PaperTrail::Version.last.id
        collapse_revisions
        expect(resource.versions.last.id).to be last_save_id
      end
    end

    context 'if no resource is passed' do
      subject(:collapse_revisions) { described_class.collapse(resource: nil, user_email: nil) }

      # Don't save it. Let it blow up and make it easier for us to find.
      it 'raises an exception' do
        # NoMethodError calling versions on nil
        expect { collapse_revisions }.to raise_exception NoMethodError
      end
    end
  end

  describe '.discard_and_revert' do
    subject(:discard_and_revert) { described_class.discard_and_revert(resource) }

    it 'removes all auto-save revisions' do
      2.times do
        resource.tap { |r| r.paper_trail_event = RevisionTracking::REVISABLE_EVENTS[:autosave] }.touch
      end

      expect { discard_and_revert }.to change {
        resource.versions.where(event: RevisionTracking::REVISABLE_EVENTS[:autosave]).count
      }.by(-2)
    end

    it 'restores content from before auto-save fired' do
      resource = create(:issue, text: 'ABC')
      resource.update(text: 'ABCDEF', paper_trail_event: RevisionTracking::REVISABLE_EVENTS[:autosave])

      described_class.discard_and_revert(resource)

      expect(resource.reload.text).to eq 'ABC'
    end

    it 'restores without creating a new update event' do
      resource.update(text: 'ABCDEF', paper_trail_event: RevisionTracking::REVISABLE_EVENTS[:autosave])

      expect { discard_and_revert }.not_to change {
        resource.versions.where(event: RevisionTracking::REVISABLE_EVENTS[:update]).count
      }
    end
  end
end
