# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RevisionCollapser do
  let(:resource) { create(:issue) }

  before do
    PaperTrail.enabled = true
  end

  describe '.call' do
    subject(:collapse_revisions) { described_class.call(resource) }

    it 'changes nothing when no autosaves exist' do
      expect { collapse_revisions }.to change { resource.versions.count }.by(0)
    end

    context 'when there are 3 autosave revisions' do
      # Part of this context tests what happens when multiple auto saves exist
      # although we clean everytime a new one comes in so technically there
      # should never be more than 2.
      before do
        3.times do
          resource.tap { |r| r.paper_trail_event = Activity::VALID_ACTIONS[:autosave] }.touch
        end
      end

      it 'removes all but 1 autosave' do
        expect { collapse_revisions }.to change {
          resource.versions.where(event: Activity::VALID_ACTIONS[:autosave]).count
        }.by(-2)
      end

      it 'keeps the latest autosave' do
        last_save_id = PaperTrail::Version.last.id
        collapse_revisions
        expect(resource.versions.last.id).to be last_save_id
      end

      it 'removes all autosaves when an update is present' do
        resource.tap { |r| r.paper_trail_event = Activity::VALID_ACTIONS[:update] }.touch

        expect { collapse_revisions }.to change {
          resource.versions.where(event: Activity::VALID_ACTIONS[:autosave]).count
        }.by(-3)
      end
    end

    describe 'persisting original state' do
      it 'carrys original state forward over autosaves' do
        resource = create(:issue, text: 'ABC')
        resource.update(text: 'ABCD', paper_trail_event: Activity::VALID_ACTIONS[:autosave])
        resource.update(text: 'ABCDE', paper_trail_event: Activity::VALID_ACTIONS[:autosave])
        resource.update(text: 'ABCDEF', paper_trail_event: Activity::VALID_ACTIONS[:autosave])

        described_class.call(resource)

        expect(resource.versions.last.reify.text).to eq('ABC')
      end

      it 'carrys original state forward over autosaves to final update' do
        resource = create(:issue, text: 'ABC')
        resource.update(text: 'ABCD', paper_trail_event: Activity::VALID_ACTIONS[:autosave])
        resource.update(text: 'ABCDE', paper_trail_event: Activity::VALID_ACTIONS[:autosave])
        resource.update(text: 'ABCDEF', paper_trail_event: Activity::VALID_ACTIONS[:autosave])
        resource.update(text: 'ABCDEF', paper_trail_event: Activity::VALID_ACTIONS[:update])

        described_class.call(resource)

        expect(resource.versions.last.reify.text).to eq('ABC')
      end
    end

    context 'when the last revision is an update' do
      before do
        3.times do
          resource.tap { |r| r.paper_trail_event = Activity::VALID_ACTIONS[:autosave] }.touch
        end

        resource.touch
      end

      it 'removes all autosave revisions' do
        expect { collapse_revisions }.to change {
          resource.versions.where(event: Activity::VALID_ACTIONS[:autosave]).count
        }.by(-3)
      end

      it 'keeps the latest update revision' do
        last_save_id = PaperTrail::Version.last.id
        collapse_revisions
        expect(resource.versions.last.id).to be last_save_id
      end
    end

    context 'if no resource is passed' do
      subject(:collapse_revisions) { described_class.call(nil) }

      # Don't save it. Let it blow up and make it easier for us to find.
      it 'raises an exception' do
        # NoMethodError calling versions on nil
        expect { collapse_revisions }.to raise_exception NoMethodError
      end
    end
  end
end
