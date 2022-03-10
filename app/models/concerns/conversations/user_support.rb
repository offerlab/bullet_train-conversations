module Conversations::UserSupport
  extend ActiveSupport::Concern

  included do
    has_many :conversations_subscriptions, through: :memberships
    has_many :conversations_messages, through: :memberships
  end
end
