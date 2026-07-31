Dradis::Plugins::Echo::Engine.routes.draw do
  scope '/addons/echo' do
    resources :agents, only: [:index, :edit, :update]
    resources :providers, except: [:show]

    resources :projects, only: [] do
      scope module: 'projects' do
        resources :interactions, only: [:index, :show, :create] do
          get :preview, on: :member
        end

        resources :grammar_corrections, only: [:create]
        resources :grammar_suggestions, only: [:create]

        resources :sessions, only: [:index, :show, :create] do
          scope module: 'sessions' do
            resource :reply, only: [:create]
            resources :messages, only: [:create]
          end
        end
      end
    end

    resources :prompts, except: [:show]
  end
end
