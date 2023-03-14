# Preview all emails at http://localhost:3000/rails/mailers/user
class SSJMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/invite
  def invite
    SSJMailer.invite(User.first, User.last)
  end
end
