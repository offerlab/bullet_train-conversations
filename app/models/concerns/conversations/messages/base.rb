module Conversations::Messages::Base
  extend ActiveSupport::Concern

  included do
    belongs_to :conversation
    belongs_to :message, optional: true
    belongs_to :membership, optional: true
    belongs_to :participant, polymorphic: true, optional: true
    has_one :user, through: :membership
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
      ActionCable.server.broadcast(broadcast_key, {})
    end

    after_save :create_subscriptions_to_conversation, :mark_subscription_as_read

    if BulletTrain::Conversations.parent_association.present?
      has_one BulletTrain::Conversations.parent_association, through: :conversation
    end

    if BulletTrain::Conversations.parent_class_specified?
      # TODO I don't know whether this is the right thing to do here, but the goal here is to provide support for
      # the situation where `Team` is on a different database than `Workspace`.
      delegate :team, to: BulletTrain::Conversations.parent_association
    end
  end

  def user_name
    membership&.name || participant&.name
  end

  def author
    user || participant
  end

  def label_string
    "this message"
  end

  def broadcast_key
    "#{conversation.subject.class.to_s.downcase}_#{conversation.subject&.id}_conversation"
  end

  def parent
    BulletTrain::Conversations.parent_association.present? ? send(BulletTrain::Conversations.parent_association) : nil
  end

  def mentioned_memberships
    Nokogiri::HTML(body).css('a[href^="bullettrain://memberships/"]').map do |mention|
      membership_id = mention["href"].split("/").last.to_i
      conversation.parent.memberships.find_by(id: membership_id)
    end.compact
  end

  def mentioned_teams
    Nokogiri::HTML(body).css('a[href^="bullettrain://teams/"]').map do |mention|
      team_id = mention["href"].split("/").last.to_i
      conversation.team.id == team_id ? conversation.team : nil
    end.compact
  end

  def create_subscriptions_to_conversation
    conversation.create_subscriptions_for_participants([participant]) if participant.present?
    conversation.create_subscriptions_for_memberships([membership]) if membership.present?
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
