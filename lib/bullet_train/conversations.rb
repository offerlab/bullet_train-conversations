require "bullet_train/conversations/version"
require "bullet_train/conversations/engine"
require "bullet_train/conversations/scaffolder"

module BulletTrain
  module Conversations
    # NOTE We specifically don't try to support namespaced replacements for `Team`.
    mattr_accessor :parent_class, default: "Team"
    mattr_accessor :base_class, default: "ApplicationRecord"

    def self.parent_association
      parent_class.underscore.to_sym
    end

    def self.parent_resource
      parent_class.underscore.pluralize.to_sym
    end

    def self.parent_class_specified?
      parent_class != "Team"
    end
  end
end
