class RemoveUnreadSinceFromConversationsSubscriptions < ActiveRecord::Migration[5.2]
  def change
    remove_column :conversations_subscriptions, :unread_since, :datetime
    add_column :conversations_subscriptions, :last_read_at, :datetime
  end
end
