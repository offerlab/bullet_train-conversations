module HasConversation
  extend ActiveSupport::Concern

  included do
    # e.g. "projects_milestone_id"
    foreign_key = (self.name.underscore.gsub("/", "_") + "_id").to_sym
    has_one :conversation, foreign_key: foreign_key, dependent: :destroy
    after_create :create_conversation_on_team
  end

  def create_conversation_on_team
    conversation || create_conversation(team: team)
  end
end
