class Conversations::SubscriptionMailboxTest < ActionMailbox::TestCase
  let(:team) {
    team = FactoryBot.build :team
    team.save(validate: false) && team
  }
  let(:user) { FactoryBot.create :user }
  let(:membership) { FactoryBot.create(:membership, team: team, user: user) }
  let(:conversation) { Conversation.create(team: team) }
  let(:subscription) { FactoryBot.create(:conversations_subscription, membership: membership, conversation: conversation)}

  test "A user can reply to a message notification" do
    assert_difference -> { conversation.messages.count } do
      receive_inbound_email_from_mail \
        to: subscription.inbound_email_address,
        from: user.email,
        subject: "Re: Notification",
        body: <<~BODY
          Hello there.
          This is a reponse.

          On Tue, 7 Jun 2022 at 06:11, John Smith <john.smith@example.com> wrote:

          > This is the notification
          > This is also the notification
        BODY
    end

    message = conversation.messages.last
    assert_equal membership, message.membership
    assert_match "Hello there.", message.body
    assert_no_match "This is the notification", message.body
    assert_nil message.participant
  end

  let(:participant) { FactoryBot.create(:customer, team: team) }
  let(:participant_subscription) { FactoryBot.create(:conversations_subscription, membership: nil, participant: participant, conversation: conversation)}

  test "A participant can reply to a message notification" do
    assert_difference -> { conversation.messages.count } do
      receive_inbound_email_from_mail \
        to: participant_subscription.inbound_email_address,
        from: "customer@example.com",
        subject: "Re: Notification",
        body: <<~BODY
          Hello there.
          This is a reponse.

          On Tue, 7 Jun 2022 at 06:11, John Smith <john.smith@example.com> wrote:

          > This is the notification
          > This is also the notification
        BODY
    end

    message = conversation.messages.last
    assert_equal participant, message.participant
    assert_match "Hello there.", message.body
    assert_no_match "This is the notification", message.body
    assert_nil message.membership
  end
end
