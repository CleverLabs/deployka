# frozen_string_literal: true

Rails.application.routes.draw do
  root "home#index"
  get "/auth/:provider/callback", to: "sessions#create"
  resources :home, only: %i[index]
  resource :sessions, only: %i[create destroy]
  resources :repos, only: %i[create show index] do
    resources :secrets, only: %i[index create]
  end

  resources :projects do
    resources :project_instances do
      resource :reload, only: %i[create], module: :project_instances
    end
    resources :deployment_configurations
  end
end
