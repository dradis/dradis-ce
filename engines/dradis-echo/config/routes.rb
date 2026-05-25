Dradis::Plugins::Echo::Engine.routes.draw do
  scope '/addons/echo' do
    resources :agents, only: [:index, :edit, :update]
    resources :providers, except: [:show]

    resources :projects, only: [] do
      resources :interactions, only: [:index, :show, :create], controller: 'projects/interactions' do
        get :preview, on: :member
      end
    end

    resources :prompts, except: [:show]
  end
end
