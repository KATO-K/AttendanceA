Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :bases do
  end

  resources :users do
      
    collection {post :import}
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month' 
      get 'attendances/edit_overtime'
      patch 'attendances/update_overtime'
      get 'attendances/edit_apply_overtime'
      patch 'attendances/update_apply_overtime'
      get 'attendances/edit_apply_one_month'
      patch 'attendances/update_apply_one_month'
      get 'attendances/edit_manager'
      patch 'attendances/update_manager'
      get 'attendances/edit_apply_manager'
      patch 'attendances/update_apply_manager'
      get 'attendances/log_attendances'
      get 'in_attendance'
      get 'basic_info'
      get 'show_confirmation'
    end
    resources :attendances, only: :update

  end
end
