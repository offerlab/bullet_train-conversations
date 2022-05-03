require "scaffolding"
require "scaffolding/transformer"

desc "Explaining what the task does"
namespace :bullet_train do
  namespace :conversations do
    task install: :environment do
      root_path = File.expand_path("../../../..", __FILE__)

      puts ""
      puts "Copying migrations.".blue
      Rake::Task["bullet_train_conversations_engine:install:migrations"].invoke
      puts "Done.".green
      puts ""

      puts "Copying `app/models/conversation.rb` from `bullet_train-conversations` into local repository.".blue
      target = # {Rails.root.to_s}/app/models/conversation.rb
        if File.exist?("./app/models/conversation.rb")
          puts "`./app/models/conversation.rb` already exists.".red
        else
          `cp #{root_path}/app/models/conversation.rb #{Rails.root}/app/models/conversation.rb`
          puts "Done.".green
          puts ""
        end

      puts "Adding conversation support concerns to `Membership` and `User` models.".blue
      transformer = Scaffolding::Transformer.new("None", "None")
      transformer.add_line_to_file("app/models/membership.rb", "include Conversations::MembershipSupport", Scaffolding::Transformer::CONCERNS_HOOK, prepend: true)
      transformer.add_line_to_file("app/models/user.rb", "include Conversations::UserSupport", Scaffolding::Transformer::CONCERNS_HOOK, prepend: true)
      puts "Done.".green
      puts ""

      puts "Adding conversation abilities support to `app/models/ability.rb`.".blue
      transformer.add_line_to_file("app/models/ability.rb", "include Conversations::AbilitySupport", "include Roles::Permit")
      transformer.add_line_to_file("app/models/ability.rb", "permit_conversations(user)", "if user.developer?", prepend: true)
      transformer.add_line_to_file("app/models/ability.rb", "# 🚅 super scaffolding will insert any new resources with conversations above.\n\n", "if user.developer?", prepend: true)
      puts "Done.".green
      puts ""

      puts "Adding the conversations inbox to the application menu.".blue
      transformer.add_line_to_file("app/views/account/shared/_menu.html.erb", "<%= render 'account/conversations/menu_item' %>\n\n", "<% unless hide_team_resource_menus? %>", increase_indent: true)
      puts "Done.".green
      puts ""
    end
  end
end
