module HasConversation
  extend ActiveSupport::Concern

  included do
    # e.g. "projects_milestone_id"
    foreign_key = (name.underscore.tr("/", "_") + "_id").to_sym
    has_one :conversation, class_name: 'Conversation', foreign_key: foreign_key, dependent: :destroy
  end

  def create_conversation_on_team
    conversation.persisted? ? conversation : create_conversation(new_conversation_attributes)
  end

  def conversation
    super || build_conversation(new_conversation_attributes)
  end

  def new_conversation_attributes
    # e.g. {team: team}
    { BulletTrain::Conversations.parent_association => send(BulletTrain::Conversations.parent_association) }
  end
end
