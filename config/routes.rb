Rails.application.routes.draw do
  root "hot_catch_apps#index"

  resources :users
  resources :hot_catch_apps

  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout
  post 'try_login' => 'user_sessions#create', :as => :try_login
  get 'signup' => 'users#new', :as => :signup
  get 'user_sessions/insufficient_privileges', as: :ip


  post "main_hot_catch_logs", to: "main_hot_catch_logs#create"
end
