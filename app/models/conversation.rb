class Conversation < ApplicationRecord
  # 🚫 DEFAULT BULLET TRAIN CONVERSATION FUNCTIONALITY
  # Typically you should avoid adding your own functionality in this section to avoid merge conflicts in the future.
  # (If you specifically want to change Bullet Train's default behavior, that's OK and you can do that here.)

  include Sprinkles::Broadcasted

  belongs_to :team

  # resources with conversations by default.
  belongs_to :kanban_card, class_name: "Kanban::Card", optional: true

  # messages.
  has_many :messages, class_name: "Conversations::Message", dependent: :destroy
  belongs_to :last_message, class_name: "Conversations::Message", optional: true

  # user subscriptions.
  has_many :subscriptions, class_name: "Conversations::Subscription", dependent: :destroy
  has_many :active_subscriptions, class_name: "Conversations::Subscription"
  has_many :memberships, through: :active_subscriptions
  has_many :users, through: :active_subscriptions

  before_destroy do
    update(last_message: nil)
  end

  # ✅ YOUR APPLICATION'S CONVERSATION FUNCTIONALITY
  # This is the place where you should implement your own features on top of Bullet Train's conversation functionality.
  # There are a bunch of Super Scaffolding hooks here by default to try and help keep generated code logically
  # organized.

  # 🚅 add concerns above.

  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.

  # 🚅 add oauth providers above.

  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  def subject
    bullet_train_subjects # 🚅 add resources with conversations above.
  end

  # 🚅 add methods above.

  # 🚫 DEFAULT BULLET TRAIN CONVERSATION FUNCTIONALITY
  # We put these at the bottom of this file to keep them out of the way. You should define your own methods above here.

  def bullet_train_subjects
    kanban_card
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

  def broadcast
    active_subscriptions.find_each do |subscription|
      Membership.broadcast_collection(subscription.membership_id, :conversations_subscriptions)
      if subscription.membership.user_id
        User.broadcast_collection(subscription.membership.user_id, :conversations_subscriptions)
      end
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
end
