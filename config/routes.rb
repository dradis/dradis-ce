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
  get '/summary' => 'projects#show'

  resources :activities, only: [] do
    collection do
      get :poll, constraints: { format: /js/ }
    end
  end

  resources :configurations, only: [:index, :update]

  resources :issues do
    collection do
      post :import
      put  :combine
    end
    resources :revisions, only: [:index, :show]
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

    resources :notes do
      resources :revisions, only: [:index, :show]
    end

    resources :evidence, except: :index do
      resources :revisions, only: [:index, :show]
    end

    constraints(:id => /.*/) do
      resources :attachments
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
  get  '/upload/status' => 'upload#status'

  root to: 'home#index'
end
