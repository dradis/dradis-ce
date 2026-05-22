Dradis::Plugins::Echo::Engine.routes.draw do
  scope '/addons/echo' do
    resources :agents, only: [:index, :edit, :update]
    resources :providers, except: [:show]

    resources :projects, only: [] do
      resources :interactions, only: [:index, :show, :create], controller: 'projects/interactions' do
        get :preview, on: :member
      end

      resource  :grammar_check,        only: [:create], controller: 'projects/grammar_checks'
      resources :grammar_replacements, only: [:create], controller: 'projects/grammar_replacements'
    end

    resources :prompts, except: [:show]
  end
end
