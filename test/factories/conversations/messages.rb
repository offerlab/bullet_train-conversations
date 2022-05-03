FactoryBot.define do
  factory :conversations_message, class: "Conversations::Message" do
    association :conversation
    association :message
    association :membership
    author_name { "MyString" }
    body { "MyText" }
  end
end
