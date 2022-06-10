namespace :cron do

  task send_users_notifications_email: :environment do
    User.send_notifications_emails
  end

end
