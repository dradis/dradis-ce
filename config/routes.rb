Rails.application.routes.draw do
  # ------------------------------------------------------------ Authentication
  # These routes allow users to set the shared password
  get  '/setup' => 'sessions#init'
  post '/setup' => 'sessions#setup'

  # Sign in / sign out
  get '/login'  => 'sessions#new'
  get '/logout' => 'sessions#destroy'
  resource :session

  # ------------------------------------------------------------ Project routes
  concern :multiple_destroy do
    collection do
      delete :multiple_destroy
    end
  end

  resources :projects, only: [:show] do
    resources :comments
    resources :issues, concerns: :multiple_destroy do
      collection do
        post :import
        resources :merge, only: [:new, :create], controller: 'issues/merge'
      end

      resources :nodes, only: [:show], controller: 'issues/nodes'
      resources :revisions, only: [:index, :show]
    end
  end

  resources :activities, only: [] do
    collection do
      get :poll, constraints: { format: /js/ }
    end
  end

  resources :configurations, only: [:index, :update]

  resources :console, only: [] do
    collection { get :status }
  end

  resources :methodologies do
    collection { post :preview }
    member do
      get :add
      put :update_task
    end
  end

  resources :nodes do
    collection do
      post :sort
      post :create_multiple
    end

    member do
      get :tree
    end

    resources :notes, concerns: :multiple_destroy do
      resources :revisions, only: [:index, :show]
    end

    resources :evidence, except: :index, concerns: :multiple_destroy do
      resources :revisions, only: [:index, :show]
    end

    constraints(:filename => /.*/) do
      resources :attachments, param: :filename
    end
  end

  get 'search' => 'search#index'
  post 'create_multiple_evidences' => 'evidence#create_multiple'
  get 'trash' => 'revisions#trash'

  resources :revisions, only: [] do
    member { post :recover }
  end

  # -------------------------------------------------------------- Static pages
  # jQuery Textile URLs
  get '/preview' => 'home#textilize',  as: :preview, defaults: { format: 'json' }
  get '/markup-help' => 'home#markup_help', as: :markup


  # ------------------------------------------------------------ Export Manager
  get  '/export'                   => 'export#index',             as: :export_manager
  post '/export'                   => 'export#create'
  get  '/export/validate'          => 'export#validate',          as: :validate_export
  get  '/export/validation_status' => 'export#validation_status', as: :validation_status

  # ------------------------------------------------------------ Upload Manager
  get  '/upload'        => 'upload#index',  as: :upload_manager
  post '/upload'        => 'upload#create'
  post '/upload/parse'  => 'upload#parse'

  root to: 'home#index'

  mount ActionCable.server => '/cable'
end
