class Account::ApplicationController < ApplicationController
  include Account::Controllers::Base

  def ensure_onboarding_is_complete
    true
  end

  # Hardcoding these Devise methods here so our tests don't need to worry about authentication.
  def current_user
    User.last
  end
  helper_method :current_user

  def user_signed_in?
    true
  end

  def authenticate_user!
  end
end
