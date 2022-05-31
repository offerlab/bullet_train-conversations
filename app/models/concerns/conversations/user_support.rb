module Conversations::UserSupport
  extend ActiveSupport::Concern

  included do
    has_many :conversations_subscriptions, through: :memberships
    has_many :conversations_messages, through: :memberships
    has_many :conversations, through: :conversations_subscriptions
    scope :with_unread_subscriptions, -> { distinct.joins(:conversations_subscriptions).merge(Conversations::Subscription.unread).reorder(nil) }
    scope :with_pending_notifications, -> {
      with_unread_subscriptions
        .joins(:conversations)
        .where("conversations.last_message_at > COALESCE(users.last_notification_email_sent_at, users.created_at)")
    }
  end

  def send_notifications_email
    # protect ourselves from accidentally sending a notification email too soon after the last.
    # TODO disabling for now, but i'll consider re-enabling this again in the future.
    # return if last_notification_email_sent_at && last_notification_email_sent_at > 10.minutes.ago
    since = last_notification_email_sent_at || created_at
    outstanding_conversations_subscriptions = conversations_subscriptions.unread_since(since)
    if outstanding_conversations_subscriptions.any?
      self.last_notification_email_sent_at = Time.zone.now
      save
      UserMailer.notifications(self, outstanding_conversations_subscriptions.map(&:id), since).deliver_now
    end
  end
end


