Dradis::CE::API::Engine::routes.draw do
  scope path: :api do
    defaults format: 'json' do
      scope module: :v1, constraints: Dradis::CE::API::RoutingConstraints.new(version: 1, default: true) do
        resources :issues
        resources :nodes do
          resources :evidence
          resources :notes
        end
      end
    end
  end
end
