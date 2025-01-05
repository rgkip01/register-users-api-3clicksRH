# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :create, :show, :update, :destroy] do
        collection do 
          get :search
        end
      end
      resource :addresses, only: [
        :index,
        :create,
        :show,
        :update,
        :destroy
      ]
    end
  end
end