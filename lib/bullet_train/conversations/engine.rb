module BulletTrain
  module Conversations
    class Engine < ::Rails::Engine
      initializer "bullet_train.super_scaffolding.conversations.templates.register_template_path" do |app|
        # Register the base path of this package with the Super Scaffolding engine.
        BulletTrain::SuperScaffolding.template_paths << File.expand_path('../../../..', __FILE__)
        BulletTrain::SuperScaffolding.scaffolders.merge!({
          "conversations" => "BulletTrain::Conversations::Scaffolder",
        })
      end

      initializer "bullet_train.themes.register" do |app|
        BulletTrain.linked_gems << "bullet_train-conversations"
      end
    end
  end
end
