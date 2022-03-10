module Conversations::AbilitySupport
  extend ActiveSupport::Concern

  included do
  end

  def permit_conversations(user)
    can :manage, Conversation, {team: {id: user.team_ids}}
    can :manage, Conversations::Subscription, {user: {id: user.id}}
    can :manage, Conversations::Message, {conversation: {team: {id: user.team_ids}}}
  end
end
