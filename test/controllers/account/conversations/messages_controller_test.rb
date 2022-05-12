require "test_helper"

class Account::Conversations::MessagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @jane = FactoryBot.create :onboarded_user, first_name: "Jane", last_name: "Smith"
    @document = FactoryBot.create :document, name: "document with conversation", team: @jane.current_team
    @document.create_conversation_on_team
    @document.conversation.messages.create(body: 'Hello 1', membership: @jane.memberships.first)
  end

  test "Can create second message" do
    post account_conversation_conversations_messages_url(@document.conversation), params: {
      conversations_message: {
        body: 'Hello'
      }
    }

    assert_response :redirect
    @document.reload
    assert_equal @document.conversation.messages.last.body, 'Hello'
    assert_equal @document.conversation.messages.last.user, @jane
  end
end
