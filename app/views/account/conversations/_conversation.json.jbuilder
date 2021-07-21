json.extract! conversation,
  :id,
  :last_message_at,
  # 🚅 super scaffolding will insert new fields above this line.
  :created_at,
  :updated_at
json.url account_conversation_url(conversation, format: :json)
