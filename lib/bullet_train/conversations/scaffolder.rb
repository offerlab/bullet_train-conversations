module BulletTrain
  module Conversations
    class Scaffolder < SuperScaffolding::Scaffolder
      def run
        unless argv.count >= 2
          puts ""
          puts "🚅  usage: bin/super-scaffold conversation <Model> <ParentModels> [association_name]"
          puts ""
          puts "E.g. add a conversation thread to a project milestone:"
          puts "  bin/super-scaffold conversation Milestone Project,Team"
          puts ""
          puts "(You can specify a name for the association if you want to refer to the conversation by something other than `conversation`.)"
          puts ""
          standard_protip
          puts ""
          exit
        end

        child = argv[0]
        parents = argv[1] ? argv[1].split(",") : []
        parents += ["Team"]
        parents = parents.map(&:classify).uniq

        # get the attribute.
        name = argv[2].presence || "conversation"

        transformer = Scaffolding::Transformer.new(child, parents, @options)

        output = `rails g migration add_#{transformer.transform_string("scaffolding_completely_concrete_tangible_thing")}_to_conversations #{transformer.transform_string("scaffolding_completely_concrete_tangible_thing")}:references`
        if output.include?("conflict") || output.include?("identical")
          puts "\n👆 No problem! Looks like you're re-running this Super Scaffolding command. We can work with the model already generated!\n".green
        end

        migration_file_name = `grep "add_reference :conversations, :#{transformer.transform_string("scaffolding_completely_concrete_tangible_thing")}" db/migrate/*`.split(":").first

        legacy_replace_in_file(migration_file_name, "null: false", "null: true")

        if "index_conversations_on_#{transformer.transform_string("scaffolding_completely_concrete_tangible_thing")}_id".length > 63
          legacy_replace_in_file(migration_file_name, "foreign_key: true", "foreign_key: true, index: {name: '#{"index_conversations_on_#{transformer.transform_string("tangible_thing")}_id"}'}")
        end

        if name != "conversation"
          snippet = <<~HEREDOC
            def create_#{name}_on_team
              #{name} || create_#{name}(team: team)
            end
          HEREDOC

          transformer.scaffold_add_line_to_file(
            "./app/models/scaffolding/completely_concrete/tangible_thing.rb",
            snippet,
            "# 🚅 add methods above.",
            prepend: true
          )

          transformer.scaffold_add_line_to_file(
            "./app/models/scaffolding/completely_concrete/tangible_thing.rb",
            "has_one :#{name}, #{name == "conversation" ? "" : 'class_name: "Conversation", '}foreign_key: :scaffolding_completely_concrete_tangible_thing_id, dependent: :destroy",
            "# 🚅 add has_one associations above.",
            prepend: true
          )
        else
          transformer.scaffold_add_line_to_file(
            "./app/models/scaffolding/completely_concrete/tangible_thing.rb",
            "include HasConversation",
            "# 🚅 add concerns above.",
            prepend: true
          )
        end

        transformer.scaffold_add_line_to_file(
          "./app/views/account/scaffolding/completely_concrete/tangible_things/show.html.erb",
          "<%= render 'account/conversations/messages/index', conversation: @tangible_thing.#{name}, messages: @tangible_thing.#{name}.messages.oldest %>",
          "<%# 🚅 super scaffolding will insert new children above this line. %>",
          prepend: true
        )

        transformer.add_line_to_file("./app/models/ability.rb", transformer.build_conversation_ability_line.first, "# 🚅 super scaffolding will insert any new resources with conversations above.", prepend: true)

        # TODO I don't think there is any situation in which this would be needed going forward.
        # model_file_content = File.readlines(transformer.transform_string("./app/models/scaffolding/completely_concrete/tangible_thing.rb")).join
        # unless model_file_content.include?("belongs_to :team") ||
        #     model_file_content.match?(/\sdef team\s/) ||
        #     model_file_content.match?(/\sdelegate :team,/)
        #   transformer.scaffold_add_line_to_file(
        #     "./app/models/scaffolding/completely_concrete/tangible_thing.rb",
        #     "delegate :team, to: :absolutely_abstract_creative_concept",
        #     "# 🚅 add delegations above.",
        #     prepend: true
        #   )
        # end

        transformer.scaffold_add_line_to_file(
          "./app/models/conversation.rb",
          "belongs_to :scaffolding_completely_concrete_tangible_thing, class_name: 'Scaffolding::CompletelyConcrete::TangibleThing', optional: true",
          "# 🚅 add belongs_to associations above.",
          prepend: true
        )

        transformer.scaffold_add_line_to_file(
          "./app/models/conversation.rb",
          "scaffolding_completely_concrete_tangible_thing ||",
          "# 🚅 add resources with conversations above.",
          prepend: true
        )

        puts transformer.transform_string("\n1. We've generated a database migration, so please run `rake db:migrate` on the command line shell!\n").yellow
      end

      # TODO this method was removed from the global scope in super scaffolding and moved to `Scaffolding::Transformer`,
      # but this gem hasn't been updated yet.
      def legacy_replace_in_file(file, before, after)
        puts "Replacing in '#{file}'."
        target_file_content = File.read(file)
        target_file_content.gsub!(before, after)
        File.write(file, target_file_content)
      end
    end
  end
end
