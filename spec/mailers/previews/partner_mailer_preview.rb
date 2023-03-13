# Preview all emails at http://localhost:3000/rails/mailers/user
class PartnerMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/invite
  def invite
    PartnerMailer.invite(User.first, User.last)
  end
end
