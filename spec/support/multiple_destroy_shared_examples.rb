shared_examples 'a multiple_destroy json response' do
  context 'when the deletion runs in the background' do
    before { Configuration.create!(name: 'admin:max_deleted_inline', value: 0) }

    it 'returns a job id, a turbo stream tag, and the initial status html' do
      delete path, params: { ids: ids, format: :json }

      json = JSON.parse(response.body)

      expect(json['success']).to eq(true)
      expect(json['jobId']).to be_present
      expect(json['streamTag']).to include('turbo-cable-stream-source')
      expect(json['statusHtml']).to include('Working…')
    end
  end

  context 'when the deletion runs inline' do
    before { Configuration.create!(name: 'admin:max_deleted_inline', value: 100) }

    it 'does not return a job id, stream tag, or status html' do
      delete path, params: { ids: ids, format: :json }

      json = JSON.parse(response.body)

      expect(json['success']).to eq(true)
      expect(json).not_to have_key('jobId')
      expect(json).not_to have_key('streamTag')
      expect(json).not_to have_key('statusHtml')
    end
  end
end
