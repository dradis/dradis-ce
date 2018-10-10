Dradis::CE::API::Engine::routes.draw do
  concern :with_comments do
    resources :comments, only: [:index, :create]
  end

  scope path: :api do
    defaults format: 'json' do
      scope module: :v1, constraints: Dradis::CE::API::RoutingConstraints.new(version: 1, default: true) do
        resources :issues, concerns: :with_comments
        resources :evidence, only: [], concerns: :with_comments
        resources :notes, only: [], concerns: :with_comments

        resources :comments, only: [:show, :update, :destroy]

        resources :nodes do
          resources :evidence
          resources :notes
          constraints(:filename => /.*/) do
            resources :attachments, param: :filename
          end
        end
      end
    end
  end
end
