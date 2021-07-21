class CreateConversationsReadReceipts < ActiveRecord::Migration[5.2]
  def change
    create_table :conversations_read_receipts do |t|
      t.references :user, foreign_key: true
      t.references :conversation, foreign_key: true
      t.datetime :last_read_at

      t.timestamps
    end
  end
end
