class AddParticipantToConversationsSubscriptions < ActiveRecord::Migration[7.0]
  def change
    add_reference :conversations_subscriptions, :participant, polymorphic: true
  end
end
