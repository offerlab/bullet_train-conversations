module Conversations::ParticipantSupport
  extend ActiveSupport::Concern
  include Conversations::Notifiable

  included do
    has_many :conversations_subscriptions, as: :participant, class_name: "Conversations::Subscription"
    has_many :conversations, -> { distinct }, through: :conversations_subscriptions
  end
end


