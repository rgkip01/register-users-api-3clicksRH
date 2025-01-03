# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resource :users do
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
