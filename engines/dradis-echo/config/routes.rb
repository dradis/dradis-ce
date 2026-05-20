Dradis::Plugins::Echo::Engine.routes.draw do
  scope '/addons/echo' do
    resources :providers, except: [:index, :show]

    resources :configurations, only: [:index] do
      patch :update, on: :collection
    end

    resources :projects, only: [] do
      resources :interactions, only: [:index, :show, :create], controller: 'roslin/projects/interactions' do
        get :preview, on: :member
      end

      resource  :grammar_check,        only: [:create], controller: 'projects/grammar_checks'
      resources :grammar_replacements, only: [:create], controller: 'projects/grammar_replacements'
    end

    resources :prompts, except: [:show]
  end
end
