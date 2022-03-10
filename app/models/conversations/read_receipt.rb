class Conversations::ReadReceipt < BulletTrain::Conversations.base_class.constantize
  belongs_to :user
  belongs_to :conversation
end
