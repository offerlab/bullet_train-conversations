class AddLastMessageToConversation < ActiveRecord::Migration[5.2]
  def change
    add_reference :conversations, :last_message, foreign_key: {to_table: 'conversations_messages'}
  end
end
