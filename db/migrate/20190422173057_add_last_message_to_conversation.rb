class AddLastMessageToConversation < ActiveRecord::Migration[7.0]
  def change
    add_reference :conversations, :last_message, foreign_key: {to_table: "conversations_messages"}
  end
end
