class ApplicationMailbox < ActionMailbox::Base
  routing Conversations::SubscriptionMailbox::ADDRESS_REGEX => "conversations/subscription"
end
