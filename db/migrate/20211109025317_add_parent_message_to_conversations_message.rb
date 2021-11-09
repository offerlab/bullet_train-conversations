class AddParentMessageToConversationsMessage < ActiveRecord::Migration[6.1]
  def change
    add_reference :conversations_messages, :parent_message, null: true, foreign_key: {to_table: :conversations_messages}
  end
end
