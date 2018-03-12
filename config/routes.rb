Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :api do
    namespace :v01, path: '0.1' do
      resources :users, only: [:index, :show, :create, :update, :destroy] do
        resource :company, only: [:show]

        resources :missions, only: [:index, :create, :update, :destroy] do
          collection do
            post 'create_multiples'
            delete 'destroy_multiples'
          end
        end

        resource :current_location, only: [:show], controller: 'user_current_locations'
      end

      resources :companies, only: [:index, :create]

      resources :missions, only: [:index]

      resources :mission_status_types, only: [:index, :create, :update, :destroy]

      resources :mission_action_types, only: [:index, :create, :update, :destroy]

      resources :user_current_locations, only: [:index]
    end
  end

  namespace :webhook do
    post 'mission_status_type_changes' => 'mission_status_type_changes#update'
  end
end
