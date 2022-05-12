# Create the dynamically named controller with eval, and then we can reference it.
eval %{
  module #{BulletTrain::Conversations.participant_namespace}::Conversations
    class MessagesController < BulletTrain::Conversations.participant_parent_controller.constantize
    end
  end
}

"#{BulletTrain::Conversations.participant_namespace}::Conversations::MessagesController".constantize.class_eval do
  include ::Conversations::Messages::BaseController

  private

  def author
    :participant=
  end

  def author_helper
    BulletTrain::Conversations.current_participant_helper_method
  end
end





