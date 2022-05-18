class Ability
  include CanCan::Ability
  include Roles::Permit
  include Conversations::AbilitySupport

  def initialize(user)
    if user.present?
      permit_conversations(user)
    end

    can :manage, Document
  end
end
