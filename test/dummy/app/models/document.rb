class Document < ApplicationRecord
  include HasConversation

  belongs_to :team
end
