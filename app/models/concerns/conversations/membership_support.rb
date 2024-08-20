module Conversations::MembershipSupport
  extend ActiveSupport::Concern

  included do
    has_many :conversations_messages, class_name: "Conversations::Message", dependent: :destroy
    has_many :conversations_subscriptions, class_name: "Conversations::Subscription", dependent: :destroy, enable_cable_ready_updates: true, inverse_of: :membership
  end
end
