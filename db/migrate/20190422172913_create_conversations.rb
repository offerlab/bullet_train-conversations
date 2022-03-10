class CreateConversations < ActiveRecord::Migration[5.2]
  def change
    create_table :conversations do |t|
      t.references :team, foreign_key: true
      t.datetime :last_message_at
      t.string :uuid

      t.timestamps
    end
  end
end
