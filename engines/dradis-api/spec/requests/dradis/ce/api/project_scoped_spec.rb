require 'rails_helper'

describe 'API' do
  describe 'ProjectScoped' do
    include_context 'project scoped API'
    include_context 'https'
    include_context 'authorized API user'

    context 'when current_project cannot be resolved' do
      before do
        allow_any_instance_of(Dradis::CE::API::V3::NodesController)
          .to receive(:current_project).and_return(nil)
      end

      it 'renders a 404 instead of raising' do
        get '/api/nodes', env: @env

        expect(response.status).to eq(404)

        body = JSON.parse(response.body)
        expect(body['message']).to eq('ActiveRecord::RecordNotFound')
      end
    end
  end
end
