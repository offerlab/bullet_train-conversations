json.extract! message,
  :id,
  :author_name,
  :body,
  # 🚅 super scaffolding will insert new fields above this line.
  :created_at,
  :updated_at
json.url account_conversations_message_url(message, format: :json)
