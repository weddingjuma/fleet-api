Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :api do
    namespace :v01, path: '0.1' do

      namespace :admin do
        resources :companies, only: [:index, :create, :show]
      end

      resources :companies, only: [:show]

      resources :users, only: [:index, :show, :create, :update, :destroy] do
        resource :current_location, only: [:show], controller: 'user_current_locations'
      end

      resources :routes

      resources :missions, only: [:index, :create, :update, :destroy] do
        collection do
          delete '' => 'missions#destroy_multiples'
        end
      end

      resources :mission_status_types, only: [:index, :create, :update, :destroy]

      resources :mission_action_types, only: [:index, :create, :update, :destroy]

      resources :user_current_locations, only: [:index]
    end
  end

  namespace :webhook do
    post 'mission_action_changes' => 'mission_action_changes#events'
  end
end
