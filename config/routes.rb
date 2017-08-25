Rails.application.routes.draw do
  # root :to => 'users#index'
  # resources :user_sessions
  resources :users

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout
  post 'try_login' => 'user_sessions#create', :as => :try_login
  get 'signup' => 'users#new', :as => :signup

  resources :hot_catch_apps

  root "hot_catch_apps#index"

  post "main_hot_catch_logs", to: "main_hot_catch_logs#create"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
