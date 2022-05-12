require "test_helper"

class Account::ConversationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @jane = FactoryBot.create :onboarded_user, first_name: "Jane", last_name: "Smith"
    @document = FactoryBot.create :document, name: "document with conversation", team: @jane.current_team
    @message_params = {
      conversation: {
        subject_class: 'Document',
        subject_id: @document.id,
        messages_attributes: {
          '0' => {
            body: 'Hello'
          }
        }
      }
    }
  end

  test "Can create conversation and first message" do
    refute @document.conversation.persisted?

    post account_team_conversations_url(@jane.current_team), params: @message_params

    assert_response :redirect
    @document.reload
    assert @document.conversation.persisted?
    assert_equal @document.conversation.messages.first.body, 'Hello'
    assert_equal @document.conversation.messages.last.user, @jane
  end

  test "Can create a second message " do
    @document.create_conversation_on_team
    @document.conversation.messages.create(body: 'Hello 1', membership: @jane.memberships.first)

    post account_team_conversations_url(@jane.current_team), params: @message_params

    assert_response :redirect
    @document.reload
    assert_equal @document.conversation.messages.size, 2
    assert_equal @document.conversation.messages.last.body, 'Hello'
    assert_equal @document.conversation.messages.last.user, @jane
  end
end
