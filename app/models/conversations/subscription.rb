class Conversations::Subscription < ApplicationRecord
  # 🚫 DEFAULT BULLET TRAIN CONVERSATION FUNCTIONALITY
  # Typically you should avoid adding your own functionality in this section to avoid merge conflicts in the future.
  # (If you specifically want to change Bullet Train's default behavior, that's OK and you can do that here.)

  include HasUuid
  include Sprinkles::Broadcasted

  belongs_to :membership
  belongs_to :conversation

  has_many :messages, through: :conversation

  has_one :user, through: :membership

  scope :latest, -> { joins(:conversation).select("conversations_subscriptions.*, conversations.last_message_at").order("conversations.last_message_at DESC") }
  scope :unread, -> { latest.joins(:conversation).where("conversations.last_message_at IS NOT NULL AND (conversations_subscriptions.last_read_at IS NULL OR conversations_subscriptions.last_read_at < conversations.last_message_at)") }
  scope :unread_since, lambda { |timestamp| unread.where("conversations.last_message_at > ?", timestamp) }
  scope :active, -> { joins(:messages).where.not(conversations_messages: {id: nil}) }
  scope :in_sort_order, -> { includes(:messages).order("conversations_messages.created_at desc") }

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
