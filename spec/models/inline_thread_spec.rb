require 'rails_helper'

describe InlineThread do
  it { should belong_to :commentable }
  it { should belong_to :user }
  it { should belong_to(:resolved_by).optional }
  it { should belong_to(:paper_trail_version).optional }
  it { should have_many(:comments).dependent(:destroy) }

  it { should validate_presence_of :anchor }
  it { should validate_presence_of :commentable }

  describe 'anchor validation' do
    it 'rejects anchor missing required keys' do
      thread = build(
        :inline_thread,
        anchor: { 'type' => 'TextQuoteSelector' }
      )
      expect(thread).not_to be_valid
      expect(thread.errors[:anchor].first).to include('missing required keys')
    end

    it 'rejects anchor with non-integer position values' do
      thread = build(
        :inline_thread,
        anchor: {
          'type' => 'TextQuoteSelector',
          'exact' => 'test',
          'prefix' => 'before',
          'suffix' => 'after',
          'position' => { 'start' => 'foo', 'end' => 'bar' }
        }
      )
      expect(thread).not_to be_valid
      expect(thread.errors[:anchor].first).to include('position must have integer start and end')
    end

    it 'accepts a valid anchor' do
      thread = build(:inline_thread)
      expect(thread).to be_valid
    end
  end

  describe '#resolve!' do
    it 'marks the thread as resolved' do
      thread = create(:inline_thread)
      user = create(:user)

      thread.resolve!(user)

      expect(thread.reload).to be_resolved
      expect(thread.resolved_by).to eq(user)
      expect(thread.resolved_at).to be_present
    end
  end

  describe '#reopen!' do
    it 'marks a resolved thread as open' do
      user = create(:user)
      thread = create(:inline_thread, status: :resolved, resolved_by: user, resolved_at: Time.current)

      thread.reopen!(user)

      expect(thread.reload).to be_open
      expect(thread.resolved_by).to be_nil
      expect(thread.resolved_at).to be_nil
    end
  end

  describe '#quoted_text' do
    it 'returns the exact text from the anchor' do
      thread = build(:inline_thread)
      expect(thread.quoted_text).to eq('Apache bugs')
    end
  end

  describe '#outdated?' do
    it 'returns false when version_id is nil' do
      thread = build(:inline_thread, version_id: nil)
      expect(thread.outdated?).to be false
    end

    it 'returns false when commentable has no update versions' do
      thread = create(:inline_thread)
      expect(thread.outdated?).to be false
    end
  end
end
