FactoryBot.define do
  factory :conversations_subscription, class: "Conversations::Subscription" do
    association :membership
    association :conversation
    unsubscribed_at { "2019-06-13 11:32:53" }
  end
end
