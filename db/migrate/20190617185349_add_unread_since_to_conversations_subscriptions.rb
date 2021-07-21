class AddUnreadSinceToConversationsSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :conversations_subscriptions, :unread_since, :datetime
  end
end
