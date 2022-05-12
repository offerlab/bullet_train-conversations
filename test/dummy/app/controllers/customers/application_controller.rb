class Customers::ApplicationController < ActionController::Base
  include LoadsAndAuthorizesResource
  # Hardcoding these Devise methods here so our tests don't need to worry about authentication.

  def self.regex_to_remove_controller_namespace
    /^Customers::/
  end

  def current_customer
    Customer.last
  end
  helper_method :current_customer

  def customer_signed_in?
    true
  end

  def authenticate_customer
  end

  def current_ability
    @current_ability ||= Customers::Ability.new(current_customer)
  end

  def current_team
    current_customer.team
  end
end
