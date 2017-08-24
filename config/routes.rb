Rails.application.routes.draw do
  resources :hot_catch_apps
  root "hot_catch_apps#index"

  post "main_hot_catch_logs/create", as: "main_hot_catch_logs"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
