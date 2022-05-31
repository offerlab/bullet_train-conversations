namespace :cron do

  task send_users_notifications_email: :environment do
    User.with_pending_notifications.find_each do |user|
      user.send_notifications_email
    end
  end

end
