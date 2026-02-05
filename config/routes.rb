Dradis::Plugins::Echo::Engine.routes.draw do
  scope '/addons/echo' do
    resources :configurations, only: [:index] do
      patch :update, on: :collection
    end

    resources :projects, only: [] do
      resources :prompts, only: [:index, :show], module: :projects
    end
  end
end
