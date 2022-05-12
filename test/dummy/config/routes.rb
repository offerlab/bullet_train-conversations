Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  extending = {only: []}
  namespace :account do
    shallow do
      resources :teams, extending do
        resources :documents
      end
    end
  end
end
