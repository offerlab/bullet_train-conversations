class Customers::Ability
  include CanCan::Ability

  def initialize(customer)
    if customer
      can :read, Conversation
      can :manage, Conversations::Message
    end
  end
end
