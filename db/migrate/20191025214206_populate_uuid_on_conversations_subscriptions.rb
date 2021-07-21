class PopulateUuidOnConversationsSubscriptions < ActiveRecord::Migration[6.0]
  def up
    Conversations::Subscription.where(uuid: nil).find_each do |conversations_subscription|
      conversations_subscription.update_column(:uuid, SecureRandom.hex)
    end
  end

  def down
  end
end
