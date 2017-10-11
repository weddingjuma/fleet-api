Rails.application.routes.draw do
  scope module: 'api' do
    namespace :v1 do
      resources :users, only: [:index, :show]

      resources :missions
    end
  end
end
