# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityFilterService do
  let(:project) { create(:project) }
  let(:activities) { project.activities.includes(:trackable) }
  let(:filter_params) { {} }

  subject { described_class.new(activities, filter_params).call }

  describe '#call' do
    context 'when no filters are applied' do
      it 'returns all activities' do
        expect(subject).to eq(activities)
      end
    end

    context 'when filtering by user_id' do
      let(:user) { create(:user) }
      let!(:activity) { create(:activity, project: project, user: user) }
      let(:filter_params) { { user_id: user.id } }

      it 'returns activities for the specified user' do
        expect(subject).to eq([activity])
      end
    end

    context 'when filtering by trackable_type' do
      let!(:activity1) { create(:activity, project: project, trackable_type: 'Issue') }
      let!(:activity2) { create(:activity, project: project, trackable_type: 'Comment') }
      let(:filter_params) { { trackable_type: 'Issue' } }

      it 'returns activities of the specified trackable type' do
        expect(subject).to eq([activity1])
      end
    end

    context 'when filtering by specific date' do
      let!(:date_activity) { create(:activity, project: project, created_at: Date.yesterday) }
      let(:filter_params) { { date: Date.yesterday.to_s } }

      it 'returns activities created on the specified date' do
        expect(subject).to eq([date_activity])
      end
    end

    context 'when filtering by date range' do
      let!(:start_date_activity) { create(:activity, project: project, created_at: Date.yesterday) }
      let!(:end_date_activity) { create(:activity, project: project, created_at: Date.tomorrow) }
      let(:filter_params) { { start_date: Date.yesterday.to_s, end_date: Date.tomorrow.to_s } }

      it 'returns activities within the specified date range' do
        expect(subject).to contain_exactly(start_date_activity, end_date_activity)
      end
    end

    context 'when invalid date formats are provided' do
      let!(:activity) { create(:activity, project: project, created_at: Date.yesterday) }
      let(:filter_params) { { date: 'invalid-date' } }

      it 'ignores the invalid date filter and returns all activities' do
        expect(subject).to eq(activities)
      end

      it 'ignores the invalid date range and returns all activities' do
        invalid_range_params = { start_date: 'invalid-start', end_date: 'invalid-end' }
        expect(subject).to eq(activities)
      end
    end
  end
end
