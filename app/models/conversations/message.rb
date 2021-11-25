class Conversations::Message < ApplicationRecord
  # 🚫 DEFAULT BULLET TRAIN CONVERSATION FUNCTIONALITY
  # Typically you should avoid adding your own functionality in this section to avoid merge conflicts in the future.
  # (If you specifically want to change Bullet Train's default behavior, that's OK and you can do that here.)

  include Sprinkles::Broadcasted

  belongs_to :conversation
  belongs_to :message, optional: true
  belongs_to :membership, optional: true
  belongs_to :user, optional: true
  belongs_to :parent_message, optional: true, class_name: "Conversations::Message"
  has_one :last_message_conversation, class_name: "Conversation", foreign_key: :last_message_id, dependent: :nullify
  has_many :replies, class_name: "Conversations::Message", foreign_key: :parent_message_id, dependent: :destroy # Should we destroy replies when a message is deleted?

  scope :before, lambda { |timestamp| where("created_at < ?", timestamp) }
  scope :since, lambda { |timestamp| where("created_at > ?", timestamp) }
  scope :without_replies, -> { where(parent_message: nil) }

  validates :body, presence: true

  before_save do
    self.author_name = user_name if user_name
  end

  after_save do
    conversation.update_last_message
    conversation.mark_read_for_membership(membership)
    conversation.broadcast
  end

  after_save :create_subscriptions_to_conversation, :mark_subscription_as_read

  delegate :team, to: :conversation

  # ✅ YOUR APPLICATION'S CONVERSATION FUNCTIONALITY
  # This is the place where you should implement your own features on top of Bullet Train's functionality. There
  # are a bunch of Super Scaffolding hooks here by default to try and help keep generated code logically organized.

  # 🚅 add concerns above.

  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.

  # 🚅 add oauth providers above.

  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  # 🚅 add methods above.

  # 🚫 DEFAULT BULLET TRAIN CONVERSATION FUNCTIONALITY
  # We put these at the bottom of this file to keep them out of the way. You should define your own methods above here.

  def user_name
    membership.name
  end

  def label_string
    "this message"
  end

  def mentioned_memberships
    Nokogiri::HTML(body).css('a[href^="bullettrain://memberships/"]').map do |mention|
      membership_id = mention["href"].split("/").last.to_i
      conversation.team.memberships.find_by(id: membership_id)
    end.compact
  end

  def mentioned_teams
    Nokogiri::HTML(body).css('a[href^="bullettrain://teams/"]').map do |mention|
      team_id = mention["href"].split("/").last.to_i
      conversation.team.id == team_id ? conversation.team : nil
    end.compact
  end

  def create_subscriptions_to_conversation
    conversation.create_subscriptions_for_memberships([membership])
    conversation.create_subscriptions_for_memberships(mentioned_memberships)
    mentioned_teams.each do |mentioned_team|
      conversation.create_subscriptions_for_memberships(mentioned_team.memberships)
    end
  end

  def mark_subscription_as_read
    return unless membership.present?
    conversation.subscriptions.where(membership: membership).map(&:mark_read)
  end

  def update_mention_labels
    html = Nokogiri::HTML.fragment(body)
    html.css('a[href^="bullettrain://memberships/"]').map do |mention|
      membership_id = mention["href"].split("/").last.to_i
      membership = Membership.find membership_id
      mention.children.first.content = membership.name
    end
    html.css('a[href^="bullettrain://teams/"]').map do |mention|
      team_id = mention["href"].split("/").last.to_i
      team = Team.find team_id
      mention.children.first.content = team.name
    end
    update(body: html)
  end

  def mark_subscriptions_unread
    conversation.active_subscriptions.find_each do |subscription|
      subscription.mark_unread
    end
  end

  def reply?
    parent_message.present?
  end

  def next_message_in_thread
    return replies.oldest.first if replies.any?
    return nil unless parent_message_id.present?
    parent_message.replies.where("created_at > ?", created_at).oldest.first
  end

  def threaded?
    reply? || replies.any?
  end

  def thread_origin_user
    return nil unless threaded?
    (parent_message || self).membership.user
  end

  def previous_message
    conversation.messages.newest.where("created_at < ?", created_at).first
  end

  def previous_message_in_thread
    return nil unless parent_message_id.present?
    parent_message.replies.where("created_at < ?", created_at).newest.first || parent_message
  end

  def thread_origin_message
    return nil unless threaded?
    parent_message || self
  end

  def next_message
    conversation.messages.oldest.where("created_at > ?", created_at).first
  end

  def thread_id
    return nil unless threaded?
    thread_origin_message.id
  end
end
