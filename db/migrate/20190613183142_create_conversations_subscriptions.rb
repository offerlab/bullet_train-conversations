class CreateConversationsSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :conversations_subscriptions do |t|
      t.references :membership, foreign_key: true
      t.references :conversation, foreign_key: true
      t.datetime :unsubscribed_at
      t.datetime :last_read_at

      t.timestamps
    end
  end
end
