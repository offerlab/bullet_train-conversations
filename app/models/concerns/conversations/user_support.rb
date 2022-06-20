module Conversations::UserSupport
  extend ActiveSupport::Concern
  include Conversations::Notifiable

  included do
    has_many :conversations_subscriptions, through: :memberships, inverse_of: :user
    has_many :conversations, -> { distinct }, through: :conversations_subscriptions
  end
end


