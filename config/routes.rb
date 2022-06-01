extending = {only: []}

Rails.application.routes.draw do
  namespace :account do
    shallow do
      # e.g. `resources :teams, extending do`
      resources BulletTrain::Conversations.parent_resource, extending do
        resources :conversations, only: [:show, :create, :update] do
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

  if BulletTrain::Conversations.participant_namespace.present?
    namespace BulletTrain::Conversations.participant_namespace.underscore.to_sym do
      shallow do
       resources BulletTrain::Conversations.participant_parent_resource, extending do
         resources :conversations, only: [:show, :create, :update], controller: '/participants/conversations' do
           namespace :conversations do
             resources :messages, controller: '/participants/conversations/messages'  do
               member do
                  get :reply
                  get :thread
               end
             end
           end
         end
       end
      end
    end
  end
end
