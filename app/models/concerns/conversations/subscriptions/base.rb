module Conversations::Subscriptions::Base
  extend ActiveSupport::Concern

  included do
    include HasUuid

    belongs_to :membership
    belongs_to :conversation

    has_many :messages, through: :conversation

    has_one :user, through: :membership

    scope :latest, -> { joins(:conversation).select("conversations_subscriptions.*, conversations.last_message_at").order("conversations.last_message_at DESC") }
    scope :unread, -> { latest.joins(:conversation).where("conversations.last_message_at IS NOT NULL AND (conversations_subscriptions.last_read_at IS NULL OR conversations_subscriptions.last_read_at < conversations.last_message_at)") }
    scope :unread_since, lambda { |timestamp| unread.where("conversations.last_message_at > ?", timestamp) }
    scope :active, -> { joins(:messages).where.not(conversations_messages: {id: nil}) }
    scope :in_sort_order, -> { includes(:messages).order("conversations_messages.created_at desc") }

    has_one BulletTrain::Conversations.parent_association, through: :conversation

    if BulletTrain::Conversations.parent_class_specified?
      # TODO I don't know whether this is the right thing to do here, but the goal here is to provide support for
      # the situation where `Team` is on a different database than `Workspace`.
      delegate :team, to: BulletTrain::Conversations.parent_association
    end
  end

  def subject
    conversation.subject.label_string
  end

  def subscribed?
    unsubscribed_at.nil?
  end

  def oldest_unread_message
    newest_message
  end

  def newest_message
    conversation.newest_message
  end

  def mark_read
    if !last_read_at || !conversation.last_message_at || last_read_at < conversation.last_message_at
      self.last_read_at = Time.zone.now
      save
      return true
    end
    false
  end

  def unread?
    return false unless conversation.last_message_at
    return true unless last_read_at
    last_read_at < conversation.last_message_at
  end

  def unread_messages_since(timestamp)
    # get messages from after either their timestamp, or the last time the user read the conversation.
    conversation.messages.oldest.since([timestamp, last_read_at].compact.max)
  end

  def unread_messages_with_context_since(timestamp)
    messages = unread_messages_since(timestamp)
    [conversation.message_before(messages.first), *messages].compact
  end

  def inbound_email_url
    return nil unless inbound_email_enabled?
    "mailto:#{inbound_email_address}?subject=#{CGI.escape("Re: #{subject}")}"
  end

  def inbound_email_address
    return nil unless inbound_email_enabled?
    "conversations+#{uuid}+#{Time.zone.now.to_i}@#{ENV["INBOUND_EMAIL_DOMAIN"]}"
  end

  def add_message(body)
    conversation.messages.create({
      user: user,
      membership: user.memberships.find_by(team: conversation.team),
      body: body.lines.map { |line| line.present? ? "<p>#{line}</p>" : line }.join,
    })
  end
end
