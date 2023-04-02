Rails.application.routes.draw do
  root 'pages#dashboard'
  #get 'pages/dashboard'
  get 'admin', to: 'pages#admin'
  get 'attendance', to: 'pages#attendance'
  get 'wage_settings', to: 'wage_settings#edit'
  #get 'wage_settings/update'
  resources :employees
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
