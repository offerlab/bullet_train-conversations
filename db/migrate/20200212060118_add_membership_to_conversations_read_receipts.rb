class AddMembershipToConversationsReadReceipts < ActiveRecord::Migration[6.0]
  def up
    add_reference :conversations_read_receipts, :membership, null: true, foreign_key: true

    Conversations::ReadReceipt.all.each do |read_receipt|
      read_receipt.update(membership_id: read_receipt.user.memberships.find_by(team: read_receipt.conversation.team).id)
    end

    remove_reference :conversations_read_receipts, :user, foreign_key: true
    change_column :conversations_read_receipts, :membership_id, :bigint, null: false
  end

  def down
    change_column :conversations_read_receipts, :membership_id, :bigint, null: true
    add_reference :conversations_read_receipts, :user, foreign_key: true

    Conversations::ReadReceipt.all.each do |read_receipt|
      read_receipt.update(user_id: read_receipt.memberships.user_id)
    end

    remove_reference :conversations_read_receipts, :membership, null: true, foreign_key: true
  end
end
