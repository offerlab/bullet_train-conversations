module Conversations::Base
  extend ActiveSupport::Concern

  included do
    belongs_to BulletTrain::Conversations.parent_association, class_name: BulletTrain::Conversations.parent_class

    if BulletTrain::Conversations.parent_class_specified?
      has_one :team, through: BulletTrain::Conversations.parent_association
    end

    # messages.
    has_many :messages, class_name: "Conversations::Message", dependent: :destroy, enable_updates: true, inverse_of: :conversation
    belongs_to :last_message, class_name: "Conversations::Message", optional: true

    # user subscriptions.
    has_many :subscriptions, class_name: "Conversations::Subscription", dependent: :destroy
    has_many :active_subscriptions, class_name: "Conversations::Subscription"
    has_many :memberships, through: :active_subscriptions
    has_many :users, through: :active_subscriptions

    before_destroy do
      update(last_message: nil)
    end

    after_save do
      subscriptions.map(&:touch)
    end
  end

  def bullet_train_subjects
  end

  def mark_read_for_membership(membership)
    if subscriptions.find_by(membership: membership)&.mark_read
      save # for broadcast, but only if the subscription read receipt was actually updated.
    end
  end

  def create_subscriptions_for_memberships(memberships)
    memberships.each do |membership|
      subscriptions.find_or_create_by(membership: membership)
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end

  def newest_message
    messages.newest.first
  end

  def update_last_message
    set_last_message(newest_message)
  end

  def set_last_message(message)
    self.last_message = message
    self.last_message_at = newest_message&.updated_at
    save
  end

  def message_before(message)
    messages.oldest.before(message.created_at).last
  end

  def merge!(other)
    other.messages.update_all(conversation_id: id)
    other.subscriptions.each do |subscription|
      if memberships.include?(subscription.membership)
        # If the subscription already exists on self, we don't need an additional subscription for
        # the conversation we are merging in.
        subscription.destroy
      else
        subscription.update_columns(conversation_id: id)
      end
    end
    # We need to reload here for any associated records we have changed.
    other.reload
    other.destroy
    self
  end
end
