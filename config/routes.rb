require './app/api/api_root'

Rails.application.routes.draw do
  mount Api::ApiRoot => '/api'
end
