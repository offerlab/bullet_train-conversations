class AddUuidToConversationsSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :conversations_subscriptions, :uuid, :string
  end
end
