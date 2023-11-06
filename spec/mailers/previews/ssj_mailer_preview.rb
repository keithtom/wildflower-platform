# Preview all emails at http://localhost:3000/rails/mailers/user
class SSJMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/invite
  def invite_partner
    SSJMailer.invite_partner(User.first, User.last)
  end

  def invite
    SSJMailer.invite(User.first.id, User.last.id)
  end

  def invite_ops_guide
    SSJMailer.invite_ops_guide(User.first, SSJ::Team.first)
  end

  def login
    SSJMailer.login(User.first)
  end
end
