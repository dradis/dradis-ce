require 'rails_helper'

describe 'Nodes API' do
  include ActionDispatch::TestProcess::FixtureFile

  include_context 'project scoped API'
  include_context 'https'

  context 'as unauthenticated user' do
    [
      ['get', '/api/upload/1'],
      ['post', '/api/upload/'],
    ].each do |verb, url|
      describe "#{verb.upcase} #{url}" do
        it 'throws 401' do
          send(verb, url, params: {}, env: @env)
          expect(response.status).to eq 401
        end
      end
    end
  end

  context 'as authorized user' do
    include_context 'authorized API user'

    describe 'GET /api/upload/:job_id' do
      context 'the job is enqueued' do
        it 'responds with HTTP code 200' do
          job_id = UploadJob.create

          get "/api/upload/#{job_id}", env: @env
          expect(response.status).to eq 200
        end
      end

      context 'the job is missing' do
        it 'responds with HTTP code 404' do
          get '/api/upload/invalid_job_id', env: @env
          expect(response.status).to eq 404
        end
      end
    end

    describe 'POST /api/upload/' do
      let(:url) { '/api/upload/' }
      let(:post_upload) { post url, params: params, env: @env }
      let(:file_path) { Rails.root.join('spec', 'fixtures', 'files', 'projects', 'welcome_project.xml') }
      let(:file_fixture) { file_fixture_upload(file_path, 'plain/text') }
      let(:uploader) { 'Dradis::Plugins::Projects::Upload::Package' }

      let(:params) {
        { file: file_fixture, uploader: uploader, state: 'draft' }
      }

      it 'calls the relevant importer' do
        expect(Dradis::Plugins::Projects::Upload::Package::Importer).to(
          receive(:new).and_call_original
        )

        post_upload
      end
    end
  end
end
