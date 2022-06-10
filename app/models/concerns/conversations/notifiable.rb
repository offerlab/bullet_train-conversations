module Conversations::Notifiable
  extend ActiveSupport::Concern
  include ActionDispatch::Routing::PolymorphicRoutes
  include Rails.application.routes.url_helpers

  included do
    scope :with_unread_subscriptions, -> { distinct.joins(:conversations_subscriptions).merge(Conversations::Subscription.unread).reorder(nil) }
    scope :with_pending_notifications, -> {
      with_unread_subscriptions
        .where("conversations.last_message_at > COALESCE(#{table_name}.last_notification_email_sent_at, #{table_name}.created_at)")
    }
  end

  class_methods do
    def send_notifications_emails
      with_pending_notifications.find_each do |notifiee|
        notifiee.send_notifications_email
      end
    end
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
      Conversations::UserMailer.notifications(self, outstanding_conversations_subscriptions.map(&:id), since).deliver_now
    end
  end

  def conversation_subject_url(conversation)
    if self.class.include?(Conversations::ParticipantSupport) && BulletTrain::Conversations.participant_namespace_as_symbol.present?
      return polymorphic_url [BulletTrain::Conversations.participant_namespace_as_symbol, conversation.subject]
    end

    polymorphic_url [:account, conversation.subject]
  end
end
