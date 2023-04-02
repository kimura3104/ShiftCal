Rails.application.routes.draw do
  get 'auth/google_oauth2/callback', to: 'auth#google_oauth2_callback'
  get 'calendars/create_calendar', to: 'calendars#create_calendar'
  root 'pages#dashboard'
  #get 'pages/dashboard'
  get 'admin', to: 'pages#admin'
  get 'admin/tally', to: 'pages#tally'
  get 'attendance', to: 'pages#attendance'
  post 'attendance', to: 'calendars#record'
  get 'wage_settings', to: 'wage_settings#edit'
  #get 'wage_settings/update'
  resources :employees
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
