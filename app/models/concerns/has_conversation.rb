module HasConversation
  extend ActiveSupport::Concern

  included do
    # e.g. "projects_milestone_id"
    foreign_key = (name.underscore.tr("/", "_") + "_id").to_sym
    has_one :conversation, foreign_key: foreign_key, dependent: :destroy
    after_create :create_conversation_on_team
  end

  def create_conversation_on_team
    # e.g. conversation || create_conversation(team: team)
    conversation || create_conversation(BulletTrain::Conversations.parent_association => send(BulletTrain::Conversations.parent_association))
  end
end
