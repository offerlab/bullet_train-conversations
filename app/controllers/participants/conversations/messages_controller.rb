class Participants::Conversations::MessagesController < BulletTrain::Conversations.participant_parent_controller.constantize
  include ::Conversations::Messages::BaseController

  private

  def author
    :participant=
  end

  def author_helper
    BulletTrain::Conversations.current_participant_helper_method
  end
end
