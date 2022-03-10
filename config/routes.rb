extending = {only: []}

Rails.application.routes.draw do
  namespace :account do
    shallow do
      resources :teams, extending do
        resources :conversations do
          namespace :conversations do
            resources :messages do
              member do
                get :reply
                get :thread
              end
            end
          end
        end
      end

      resources :users, extending do
        namespace :conversations do
          resources :subscriptions do
            member do
              post :subscribe
              post :unsubscribe
            end
          end
        end
      end
    end
  end
end
