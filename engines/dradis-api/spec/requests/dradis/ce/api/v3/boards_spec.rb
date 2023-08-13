require 'rails_helper'

describe 'Boards API' do

  include_context 'project scoped API'
  include_context 'https'

  context 'as unauthenticated user' do
    [
      ['get', '/api/boards/'],
      ['get', '/api/boards/1'],
      ['post', '/api/boards/'],
      ['put', '/api/boards/1'],
      ['patch', '/api/boards/1'],
      ['delete', '/api/boards/1'],
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

    describe 'GET /api/boards' do
      before do
        @boards = create_list(:board, 30, project: current_project).sort_by(&:updated_at)
        @board_names = @boards.map(&:name)

        get "/api/boards?#{params}", env: @env

        expect(response.status).to eq(200)
        @retrieved_boards = JSON.parse(response.body)
      end

      context 'without params' do
        let(:params) { '' }

        it 'retrieves all the boards' do
          retrieved_board_names = @retrieved_boards.map{ |p| p['name'] }

          expect(@retrieved_boards.count).to eq(@boards.count)
          expect(retrieved_board_names).to match_array(@board_names)
        end
      end

      context 'with params' do
        let(:params) { 'page=2' }

        it 'retrieves the paginated boards' do
          expect(@retrieved_boards.count).to eq(5)
        end
      end
    end

    describe 'GET /api/boards/:id' do
      it 'retrieves a specific board' do
        board = create(:board, name: 'Existing Board', project: current_project)

        get "/api/boards/#{ board.id }", env: @env
        expect(response.status).to eq(200)

        retrieved_board = JSON.parse(response.body)
        expect(retrieved_board['name']).to eq board.name
      end
    end

    describe 'POST /api/boards' do
      let(:valid_post) do
        post '/api/boards', params: valid_params.to_json, env: @env.merge('CONTENT_TYPE' => 'application/json')
      end
      let(:valid_params) do
        {
          board: {
            name: 'New Board',
            node_id: current_project.methodology_library.id
          }
        }
      end

      it 'creates a new board' do
        expect{valid_post}.to change{Board.count}.by(1)
        expect(response.status).to eq(201)

        retrieved_board = JSON.parse(response.body)

        expect(response.location).to eq(dradis_api.board_url(retrieved_board['id']))

        valid_params[:board].each do |attr, value|
          expect(retrieved_board[attr.to_s]).to eq value
        end
      end

      # Activity shared example was originally written for feature requests and
      # expects a 'submit_form' let variable to be defined:
      let(:submit_form) { valid_post }
      include_examples 'creates an Activity', :create, Board

      it 'throws 415 unless JSON is sent' do
        params = { board: { } }
        post '/api/boards', params: params, env: @env
        expect(response.status).to eq(415)
      end

      it 'throws 422 if board is invalid' do
        params = { board: { name: '' } }
        post '/api/boards', params: params.to_json, env: @env.merge('CONTENT_TYPE' => 'application/json')
        expect(response.status).to eq(422)
      end

      it 'throws 422 if no :board param is sent' do
        params = { }
        post '/api/boards', params: params.to_json, env: @env.merge('CONTENT_TYPE' => 'application/json')
        expect(response.status).to eq(422)
      end

      it 'throws 400 if invalid JSON is sent' do
        invalid_tokens = ', , '
        json_payload = %Q|{"board":{"name":"A malformed name"#{ invalid_tokens }}}|
        post '/api/boards', params: json_payload, env: @env.merge('CONTENT_TYPE' => 'application/json')
        expect(response.status).to eq(400)
      end
    end

    describe 'PUT /api/boards/:id' do

      let(:board) { create(:board, name: 'Existing Board', project: current_project) }

      let(:valid_put) do
        put "/api/boards/#{ board.id }", params: valid_params.to_json, env: @env.merge('CONTENT_TYPE' => 'application/json')
      end
      let(:valid_params) { { board: { name: 'Updated Board' } } }

      it 'updates a board' do
        valid_put
        expect(response.status).to eq(200)
        expect(current_project.boards.find(board.id).name).to eq valid_params[:board][:name]
        retrieved_board = JSON.parse(response.body)
        expect(retrieved_board['name']).to eq valid_params[:board][:name]
      end

      let(:submit_form) { valid_put }
      let(:model) { board }
      include_examples 'creates an Activity', :update

      it 'throws 415 unless JSON is sent' do
        params = { board: { name: 'Bad Board' } }
        put "/api/boards/#{ board.id }", params: params, env: @env
        expect(response.status).to eq(415)
      end

      it 'throws 422 if board is invalid' do
        params = { board: { name: '' } }
        put "/api/boards/#{ board.id }", params: params.to_json, env: @env.merge('CONTENT_TYPE' => 'application/json')
        expect(response.status).to eq(422)
      end

      it 'throws 422 if no :board param is sent' do
        params = { }
        put "/api/boards/#{ board.id }", params: params.to_json, env: @env.merge('CONTENT_TYPE' => 'application/json')
        expect(response.status).to eq(422)
      end

      it 'throws 400 if invalid JSON is sent' do
        invalid_tokens = ', , '
        json_payload = %Q|{"board":{"name":"A malformed name"#{ invalid_tokens }}}|
        put "/api/boards/#{ board.id }", params: json_payload, env: @env.merge('CONTENT_TYPE' => 'application/json')
        expect(response.status).to eq(400)
      end

    end

    describe 'DELETE /api/boards/:id' do

      let(:board) { create(:board, name: 'Existing Board', project: current_project) }
      let(:delete_board) { delete "/api/boards/#{ board.id }", env: @env }

      it 'deletes a board' do
        delete_board
        expect(response.status).to eq(200)

        expect { current_project.boards.find(board.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      let(:model) { board }
      let(:submit_form) { delete_board }
      include_examples 'creates an Activity', :destroy
    end
  end

end
