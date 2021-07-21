json.extract! subscription,
  :id,
  :subject,
  # 🚅 super scaffolding will insert new fields above this line.
  :created_at,
  :updated_at
json.url account_conversations_subscription_url(subscription, format: :json)
