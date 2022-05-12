require "bullet_train/conversations/version"
require "bullet_train/conversations/engine"
require "bullet_train/conversations/scaffolder"

module BulletTrain
  module Conversations
    # NOTE We specifically don't try to support namespaced replacements for `Team`.
    mattr_accessor :parent_class, default: "Team"
    mattr_accessor :base_class, default: "ApplicationRecord"
    mattr_accessor :participant_parent_class, default: nil
    mattr_accessor :participant_namespace, default: nil
    mattr_accessor :participant_parent_class, default: nil
    mattr_accessor :participant_parent_controller, default: nil
    mattr_accessor :current_participant_helper_method, default: :current_user

    def self.parent_association
      parent_class.underscore.to_sym
    end

    def self.parent_resource
      parent_class.underscore.pluralize.to_sym
    end

    def self.parent_class_specified?
      parent_class != "Team"
    end

    def self.participant_parent_association
      return parent_association if participant_parent_class.nil?

      participant_parent_class.underscore.to_sym
    end

    def self.participant_parent_resource
      return parent_resource if participant_parent_class.nil?

      participant_parent_class.underscore.pluralize.to_sym
    end

    def self.participant_parent_controller
      return class_variable_get("@@participant_parent_controller") if class_variable_get("@@participant_parent_controller").present?
      return "#{participant_namespace}::ApplicationController" if participant_namespace.present?
      "ActionController::Base"
    end
  end
end
