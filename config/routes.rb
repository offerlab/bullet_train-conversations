extending = {only: []}

Rails.application.routes.draw do

  # This is a reuseable set of routes that we can optionally nest under a parent_resource
  # or not, depending on the configuration of the app using this gem.
  concern :conversationable do
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
  namespace :account do
    shallow do
      if BulletTrain::Conversations.parent_resource.present?
        # e.g. `resources :teams, extending do`
        resources BulletTrain::Conversations.parent_resource, extending do
          concerns :conversationable
        end
      else
        concerns :conversationable
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
