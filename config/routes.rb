Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  scope module: 'api' do
    namespace :v1 do
      resources :users, only: [:index, :show, :create, :update, :destroy] do
        resource :company

        resources :missions, only: [:index, :create, :update, :destroy]

        resources :mission_status_types, only: [:index, :create, :update, :destroy]

        resources :mission_status_actions, only: [:index, :create, :update, :destroy]
      end

      resources :missions

      resources :companies, only: [:index]
    end
  end
end
