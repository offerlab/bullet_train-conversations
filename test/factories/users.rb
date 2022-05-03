FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "generic-user-#{n}@example.com" }

    factory :onboarded_user do
      first_name { "First Name" }
      last_name { "Last Name" }
    end
  end
end
