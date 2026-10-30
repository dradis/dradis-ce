require 'rails_helper'

Dir[Dradis::Plugins::Echo::Engine.root.join('spec/factories/*.rb')].sort.each { |f| require f }

describe 'Echo agents' do
  before { login_as_user(create(:user, :admin)) }

  let(:agent) { create(:system_agent, name: Dradis::Plugins::Echo::Agents::Roslin::NAME) }

  describe 'PATCH /addons/echo/agents/:id' do
    context 'without a provider' do
      before { patch "/addons/echo/agents/#{agent.id}", params: { agent: { provider_id: '' } } }

      it 'shows the error under the provider field' do
        expect(response.body).to include('<div class="invalid-feedback">Provider must exist</div>')
      end
    end
  end
end
