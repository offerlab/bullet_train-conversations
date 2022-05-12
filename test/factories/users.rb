FactoryBot.define do
  factory :user do
    email { "generic-user-#{rand(9999999)}@example.com" }
    password { "08h4f78hrc0ohw9f8heso" }
    password_confirmation { "08h4f78hrc0ohw9f8heso" }

    factory :onboarded_user do
      first_name { "First Name" }
      last_name { "Last Name" }
      after(:create) do |user|
        default_team = user.teams.create(name: "Your Team", time_zone: 'UTC')
        user.memberships.find_by(team: default_team).update role_ids: [1]
        user.update(current_team: default_team)
      end
    end
  end
end
