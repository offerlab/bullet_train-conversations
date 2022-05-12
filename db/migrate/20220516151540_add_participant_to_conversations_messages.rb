class AddParticipantToConversationsMessages < ActiveRecord::Migration[7.0]
  def change
    add_reference :conversations_messages, :participant, polymorphic: true
  end
end
