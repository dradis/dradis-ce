# Shared examples for controllers that include EditingLock.
#
# Required let variables:
#   - record          : the model instance (note, issue, or evidence)
#   - edit_params     : params hash for GET #edit
#   - lock_params     : params hash for PATCH #lock
#   - unlock_params   : params hash for DELETE #unlock
#   - current_user    : the signed-in user
#   - other_user      : a second user (for locked-by-other scenarios)

shared_examples 'editing lock behavior' do
  let(:redis_double) { double('Redis::Namespace') }

  before do
    allow(Resque).to receive(:redis).and_return(redis_double)
  end

  describe '#edit' do
    context 'when the content is not locked' do
      before { allow(redis_double).to receive(:get).and_return(nil) }

      it 'acquires the lock and renders the edit form' do
        allow(redis_double).to receive(:set)

        get :edit, params: edit_params

        expect(redis_double).to have_received(:set)
        expect(assigns(:lock_owner)).to be_nil
        expect(response).to render_template(:edit)
      end
    end

    context 'when the content is locked by the current user' do
      before do
        allow(redis_double).to receive(:get).and_return(
          { user_id: current_user.id, user_name: current_user.name }.to_json
        )
        allow(redis_double).to receive(:expire)
      end

      it 'renews the TTL and renders the edit form' do
        get :edit, params: edit_params

        expect(redis_double).to have_received(:expire)
        expect(assigns(:lock_owner)).to be_nil
        expect(response).to render_template(:edit)
      end
    end

    context 'when the content is locked by another user' do
      before do
        allow(redis_double).to receive(:get).and_return(
          { user_id: other_user.id, user_name: other_user.name }.to_json
        )
      end

      it 'exposes @lock_owner and renders the edit template (showing interstitial)' do
        get :edit, params: edit_params

        expect(assigns(:lock_owner)).to include('user_id' => other_user.id, 'user_name' => other_user.name)
        expect(response).to render_template(:edit)
      end

      context 'with force=true' do
        it 'force-acquires the lock and renders the edit form' do
          allow(redis_double).to receive(:set)

          get :edit, params: edit_params.merge(force: 'true')

          expect(redis_double).to have_received(:set)
          expect(assigns(:lock_owner)).to be_nil
          expect(response).to render_template(:edit)
        end
      end
    end
  end

  describe '#lock' do
    context 'when the current user holds the lock' do
      before do
        allow(redis_double).to receive(:get).and_return(
          { user_id: current_user.id, user_name: current_user.name }.to_json
        )
        allow(redis_double).to receive(:expire).and_return(1)
      end

      it 'returns 200 OK' do
        patch :lock, params: lock_params

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the lock has been taken by another user' do
      before do
        allow(redis_double).to receive(:get).and_return(
          { user_id: other_user.id, user_name: other_user.name }.to_json
        )
      end

      it 'returns 409 Conflict with the new owner details' do
        patch :lock, params: lock_params

        expect(response).to have_http_status(:conflict)
        body = JSON.parse(response.body)
        expect(body).to include('user_id' => other_user.id, 'user_name' => other_user.name)
      end
    end
  end

  describe '#unlock' do
    it 'releases the lock and returns 204' do
      allow(redis_double).to receive(:get).and_return(
        { user_id: current_user.id, user_name: current_user.name }.to_json
      )
      allow(redis_double).to receive(:del)

      delete :unlock, params: unlock_params

      expect(redis_double).to have_received(:del)
      expect(response).to have_http_status(:no_content)
    end
  end
end
