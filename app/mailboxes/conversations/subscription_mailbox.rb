class Conversations::SubscriptionMailbox < ActionMailbox::Base
  include ActionView::Helpers::SanitizeHelper

  # the values being pulled out here are the uuid of the conversation subscription
  # and the timestamp when the original notification email being replied to was sent.
  ADDRESS_REGEX = /^conversations\+([0-9a-f]{32})\+(\d+)@/i

  def outbound_email_generated_at
    Time.at(mail.to.map { |address| ADDRESS_REGEX.match(address) }.first[2].to_i)
  end

  def conversations_subscription
    conversations_subscription_id = mail.to.map { |address| ADDRESS_REGEX.match(address) }.first[1]
    Conversations::Subscription.find_by(uuid: conversations_subscription_id)
  end

  def process
    body = ExtendedEmailReplyParser.parse mail
    conversations_subscription.add_message(body)
    unless conversations_subscription.last_read_at > outbound_email_generated_at
      conversations_subscription.update(last_read_at: outbound_email_generated_at)
    end
  end
end
