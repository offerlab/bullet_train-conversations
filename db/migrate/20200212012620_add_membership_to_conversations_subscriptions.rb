class AddMembershipToConversationsSubscriptions < ActiveRecord::Migration[6.0]
  def up
    add_reference :conversations_subscriptions, :membership, null: true, foreign_key: true

    Conversations::Subscription.all.each do |subscription|
      user_id = subscription.user_id
      user = User.find user_id
      subscription.update(membership_id: user.memberships.find_by(team: subscription.team).id)
    end

    remove_reference :conversations_subscriptions, :user, foreign_key: true
    change_column :conversations_subscriptions, :membership_id, :bigint, null: false
  end

  def down
    change_column :conversations_subscriptions, :membership_id, :bigint, null: true
    add_reference :conversations_subscriptions, :user, foreign_key: true

    Conversations::Subscription.all.each do |subscription|
      subscription.update(user_id: subscription.membership.user_id)
    end

    remove_reference :conversations_subscriptions, :membership, null: true, foreign_key: true
  end
end
