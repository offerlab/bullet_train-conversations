extending = {only: []}

namespaces = {account: BulletTrain::Conversations.parent_resource}
if BulletTrain::Conversations.participant_namespace.present?
  namespaces[BulletTrain::Conversations.participant_namespace.underscore.to_sym] = BulletTrain::Conversations.participant_parent_resource
end

Rails.application.routes.draw do
  namespaces.each do |conversation_namespace, parent_resource|
    namespace conversation_namespace do
      shallow do
        # e.g. `resources :teams, extending do`
        resources parent_resource, extending do
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
  end
end
