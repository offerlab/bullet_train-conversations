class User < ApplicationRecord
  include Users::Base
  include Conversations::UserSupport
  # 🚅 add concerns above.

  # 🚅 add belongs_to associations above.

  # 🚅 add has_many associations above.

  # 🚅 add oauth providers above.

  # 🚅 add has_one associations above.

  # 🚅 add scopes above.

  # 🚅 add validations above.

  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  def full_name
    "#{first_name} #{last_name}"
  end

  def invalidate_ability_cache
  end
  # 🚅 add methods above.
end
