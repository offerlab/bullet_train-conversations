class CreateConversationsSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :conversations_subscriptions do |t|
      t.references :user, foreign_key: true
      t.references :conversation, foreign_key: true
      t.datetime :unsubscribed_at

      t.timestamps
    end
  end
end
