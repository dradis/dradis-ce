require 'rails_helper'

describe IssuesHelper do
  describe '#state_badge' do
    it 'renders a badge for the record state' do
      issue = build(:issue, state: :ready_for_review)

      expect(helper.state_badge(issue)).to eq(
        '<span class="badge badge-state-ready-for-review">Ready for review</span>'
      )
    end

    it 'renders nothing when the record has no state' do
      expect(helper.state_badge(build(:issue, state: nil))).to be_nil
    end
  end
end
