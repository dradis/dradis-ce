Dradis::Plugins::Echo::Engine.routes.draw do
  scope '/addons/echo' do
    resources :agents, only: [:index, :edit, :update]
    resources :providers, except: [:show]

    resources :projects, only: [] do
      resources :interactions, only: [:index, :show, :create], controller: 'projects/interactions' do
        get :preview, on: :member
      end

      resources :grammar_corrections, only: [:create], controller: 'projects/grammar_corrections'
      resources :grammar_suggestions, only: [:create], controller: 'projects/grammar_suggestions'
    end

    resources :prompts, except: [:show]
  end
end
