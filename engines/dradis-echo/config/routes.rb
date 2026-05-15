Dradis::Plugins::Echo::Engine.routes.draw do
  scope '/addons/echo' do
    resources :providers, except: [:show]

    resources :configurations, only: [:index] do
      patch :update, on: :collection
    end

    resources :projects, only: [] do
      resources :interactions, only: [:index, :show, :create], controller: 'roslin/projects/interactions' do
        get :preview, on: :member
      end
    end

    resources :prompts, except: [:show]
  end
end
