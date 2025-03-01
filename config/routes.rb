Dradis::Plugins::Echo::Engine.routes.draw do
  scope '/addons/echo' do
    resources :configurations, only: [:index] do
      patch :update, on: :collection
    end

    resources :prompts, only: [:show]
  end
end
