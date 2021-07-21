class Conversations::ReadReceipt < ApplicationRecord
  belongs_to :user
  belongs_to :conversation
end
