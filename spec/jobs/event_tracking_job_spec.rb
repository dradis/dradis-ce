# frozen_string_literal: true
require 'rails_helper'

RSpec.describe EventTrackingJob do
  before do
    @visit = create(:visit)
  end
  
  describe '#perform' do
    it 'creates an ahoy_event entry' do
      described_class.new.perform(visit: @visit, event_name: 'Test Event', properties: {})
      expect(Ahoy::Event.last.name).to eq('Test Event')
    end
  end
end
