require "test_helper"

class UserSupportTest < ActiveSupport::TestCase
  let(:team) {
    team = FactoryBot.build :team
    team.save(validate: false) && team
  }
  let(:user) { FactoryBot.create :user }
  let(:membership) { FactoryBot.create(:membership, user: user) }
  let(:last_read) { Time.now }
  let(:conversation) { Conversation.create(team: team, last_message_at: last_read + 1) }
  let(:subscription) {
    FactoryBot.create(:conversations_subscription, membership: membership, conversation: conversation, last_read_at: last_read)
  }

  before(:each) {
    subscription
    conversation
  }

  describe "::with_pending_notifications" do
    it "includes users with pending notifications that have read the conversation" do
      assert_includes User.with_pending_notifications.to_a, user
    end

    it "includes users with pending notifications that have never read the conversation" do
      subscription.update(last_read_at: nil)

      assert_includes User.with_pending_notifications.to_a, user
    end

    it "includes users with pending notifications that have previously been notified" do
      user.update(last_notification_email_sent_at: last_read - 1)

      assert_includes User.with_pending_notifications.to_a, user
    end

    it "excludes users without pending notifications" do
      subscription.update(last_read_at: conversation.last_message_at + 1)

      refute_includes User.with_pending_notifications.to_a, user
    end
  end
end
