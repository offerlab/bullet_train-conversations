require "test_helper"

class MessageTest < ActiveSupport::TestCase
  describe "#create_subscriptions_on_conversation" do
    let(:team) {
      team = FactoryBot.build :team
      team.save(validate: false) && team
    }
    let(:user) { FactoryBot.create :user }
    let(:membership) { FactoryBot.create(:membership, team: team, user: user) }
    let(:conversation) { Conversation.create(team: team) }
    let(:participant) { FactoryBot.create(:customer, team: team) }

    describe "for memberships" do
      let(:subscription) { FactoryBot.create(:conversations_subscription, membership: membership, conversation: conversation)}

      it "Creates a subscription by the message author if none exists" do
        assert_equal conversation.subscriptions.count, 0
        Conversations::Message.create(membership: membership, conversation: conversation, body: "<div>Hello</div>")
        assert_equal conversation.subscriptions.count, 1
        assert_equal conversation.subscriptions.first.membership, membership
        assert_nil conversation.subscriptions.first.participant
      end

      it "Does not create a subscription by the message author if one exists" do
        subscription
        assert_equal conversation.subscriptions.count, 1
        Conversations::Message.create(membership: membership, conversation: conversation, body: "<div>Hello</div>")
        assert_equal conversation.subscriptions.count, 1
      end
    end

    describe "for participants" do
      let(:subscription) { FactoryBot.create(:conversations_subscription, participant: participant, conversation: conversation)}

      it "Creates a subscription by the message author if none exists" do
        assert_equal conversation.subscriptions.count, 0
        Conversations::Message.create(participant: participant, conversation: conversation, body: "<div>Hello</div>")
        assert_equal conversation.subscriptions.count, 1
        assert_equal conversation.subscriptions.first.participant, participant
        assert_nil conversation.subscriptions.first.membership
      end

      it "Does not create a subscription by the message author if one exists" do
        subscription
        assert_equal conversation.subscriptions.count, 1
        Conversations::Message.create(participant: participant, conversation: conversation, body: "<div>Hello</div>")
        assert_equal conversation.subscriptions.count, 1
      end
    end
  end
end
