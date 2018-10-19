Dradis::CE::API::Engine::routes.draw do
  concern :with_comments do
    resources :comments, only: [:index, :create]
  end

  scope path: :api do
    defaults format: 'json' do
      scope module: :v1, constraints: Dradis::CE::API::RoutingConstraints.new(version: 1, default: true) do
        resources :issues, concerns: :with_comments
        resources :comments, only: [:show, :update, :destroy]

        resources :nodes do
          resources :evidence, concerns: :with_comments
          resources :notes, concerns: :with_comments
          constraints(:filename => /.*/) do
            resources :attachments, param: :filename
          end
        end
      end
    end
  end
end
