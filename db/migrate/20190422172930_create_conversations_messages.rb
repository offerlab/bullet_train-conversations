class CreateConversationsMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :conversations_messages do |t|
      t.references :conversation, foreign_key: true
      t.references :message, foreign_key: {to_table: 'conversations_messages'}
      t.references :membership, optional: true, foreign_key: true
      t.references :user, optional: true, foreign_key: true
      t.string :author_name
      t.text :body

      t.timestamps
    end
  end
end
