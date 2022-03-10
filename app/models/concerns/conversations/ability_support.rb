module Conversations::AbilitySupport
  extend ActiveSupport::Concern

  def permit_conversations(user)
    if BulletTrain::Conversations.parent_class_specified?
      raise "`permit_conversations` doesn't support installations where a different parent class is specified for `Conversastion`. You'll have to define your permissions manually in `app/models/ability.rb` or `config/models/roles.yml`."
    end

    can :manage, Conversation, {team: {id: user.team_ids}}
    can :manage, Conversations::Subscription, {user: {id: user.id}}
    can :manage, Conversations::Message, {conversation: {team: {id: user.team_ids}}}
  end
end
