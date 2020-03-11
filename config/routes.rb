if ENV['RAILS_RELATIVE_URL_ROOT']
  Rails.application.routes.default_scope = ENV['RAILS_RELATIVE_URL_ROOT']
end

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
    resources :activities, only: [] do
      collection do
        get :poll, constraints: { format: /js/ }
      end
    end

    resources :boards do
      resources :lists, except: [:index] do
        member { post :move }
        resources :cards, except: [:index] do
          member { post :move }
          resources :revisions, only: [:index, :show]
        end
      end
    end

    resources :comments

    namespace :configurations do
      resources :tags, only: [:index, :new, :create, :edit, :update, :destroy]
    end

    constraints id: %r{[(0-z)\/]+} do
      resources :configurations, only: [:index, :update]
    end

    post :create_multiple_evidence, to: 'evidence#create_multiple'

    resources :issues, concerns: :multiple_destroy do
      collection do
        post :import
        resources :merge, only: [:new, :create], controller: 'issues/merge'
      end

      resources :nodes, only: [:show], controller: 'issues/nodes'
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

      resource :merge, only: [:create], controller: 'nodes/merge'

      resources :notes, concerns: :multiple_destroy do
        resources :revisions, only: [:index, :show]
      end

      resources :evidence, except: :index, concerns: :multiple_destroy do
        resources :revisions, only: [:index, :show]
      end

      constraints(filename: /.*/) do
        resources :attachments, param: :filename
      end
    end

    resources :notifications, only: [:index, :update]

    resources :revisions, only: [] do
      member { post :recover }
    end

    resources :subscriptions, only: [:create, :destroy]

    get 'search' => 'search#index'
    get 'trash' => 'revisions#trash'

    # ------------------------------------------------------- Export Manager
    get  '/export'                   => 'export#index',             as: :export_manager
    post '/export'                   => 'export#create'
    get  '/export/validate'          => 'export#validate',          as: :validate_export
    get  '/export/validation_status' => 'export#validation_status', as: :validation_status

    # ------------------------------------------------------- Upload Manager
    get  '/upload'        => 'upload#index',  as: :upload_manager
    post '/upload'        => 'upload#create'
    post '/upload/parse'  => 'upload#parse'

    if Rails.env.development?
      get '/styles'          => 'styles_tylium#index'
    end
  end

  resources :console, only: [] do
    collection { get :status }
  end

  # -------------------------------------------------------------- Static pages
  # jQuery Textile URLs
  get '/preview' => 'home#textilize',  as: :preview, defaults: { format: 'json' }
  get '/markup-help' => 'home#markup_help', as: :markup

  root to: 'projects#index'

  mount ActionCable.server => '/cable'
end
