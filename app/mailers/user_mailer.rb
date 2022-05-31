class UserMailer < ApplicationMailer
  helper :theme
  helper "turbo/frames"
  helper "account/conversations"
  helper "fields/html_editor"

  def notifications(user, conversations_subscription_ids, since)
    @user = user
    @since = since
    @conversations_subscriptions = conversations_subscription_ids.map { |id| user.conversations_subscriptions.find(id) }.compact

    # if we're only notifying them of updates on a single conversation thread ..
    if @conversations_subscriptions.count == 1
      @subject = I18n.t('user_mailer.notifications.subjects.subject', subject_label: @conversations_subscriptions.first.subject)

      # in this case they can add a response to the message thread by just replying to the email.
      mail(to: @user.email, subject: @subject, reply_to: @conversations_subscriptions.first.inbound_email_address)

    # if all the conversation threads we're updating them on are on the same team ..
    elsif @conversations_subscriptions.map { |cs| cs.conversation.team }.uniq.count == 1
      @subject = I18n.t('user_mailer.notifications.subjects.team', team_name: @conversations_subscriptions.first.conversation.team.name)
      mail(to: @user.email, subject: @subject)

    # if the conversation threads we're updating them on are on different teams ..
    else
      @subject = I18n.t('user_mailer.notifications.subjects.application')
      mail(to: @user.email, subject: @subject)
    end
  end
end
