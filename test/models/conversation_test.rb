require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  describe "#merge!" do
    let(:team) {
      team = FactoryBot.build :team
      team.save(validate: false) && team
    }
    let(:user) { FactoryBot.create :onboarded_user }
    let(:membership) { FactoryBot.create(:membership, team: team, user: user) }
    let(:target_conversation) { Conversation.create(team: team) }
    let(:other_conversation) { Conversation.create(team: team) }

    it "Destroys the other conversation" do
      target_conversation.merge!(other_conversation)

      assert Conversation.exists?(target_conversation.id)
      refute Conversation.exists?(other_conversation.id)
    end

    describe "Merging messages" do
      before do
        5.times do |i|
          target_conversation.messages.create(membership: membership, body: "message_#{i}")
          other_conversation.messages.create(membership: membership, body: "message_#{i}")
        end
      end

      it "copies messages from the other conversation" do
        target_conversation.merge!(other_conversation)

        assert Conversation.exists?(target_conversation.id)
        refute Conversation.exists?(other_conversation.id)

        target_conversation.reload
        assert_equal target_conversation.messages.size, 10
      end
    end

    describe "Merging subscriptions" do
      let(:user2) { FactoryBot.create :onboarded_user }
      let(:membership2) { FactoryBot.create(:membership, team: team, user: user2) }
      let(:target_subscription) { target_conversation.subscriptions.create(membership: membership) }

      it "Deletes the subscription from the other conversation if it would be a duplicate on the target conversation" do
        target_subscription
        other_subscription = other_conversation.subscriptions.create(membership: membership)

        target_conversation.merge!(other_conversation)

        assert Conversations::Subscription.exists?(target_subscription.id)
        refute Conversations::Subscription.exists?(other_subscription.id)
      end

      it "Moves a subscription to the target conversation if one does not already exist for the membership" do
        target_subscription
        other_subscription = other_conversation.subscriptions.create(membership: membership2)

        target_conversation.merge!(other_conversation)

        assert Conversations::Subscription.exists?(target_subscription.id)
        assert Conversations::Subscription.exists?(other_subscription.id)

        other_subscription.reload
        assert_equal other_subscription.conversation_id, target_conversation.id
      end
    end
  end
end
