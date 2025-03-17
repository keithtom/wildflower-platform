# Preview all emails at http://localhost:3000/rails/mailers/login_mailer
class LoginMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/login_mailer/password_reset
  def password_reset
    user = User.first || FactoryBot.create(:user,
                                           email: 'test@example.com',
                                           first_name: 'Test',
                                           last_name: 'User')

    Users::GenerateToken.call(user)
    LoginMailer.password_reset(user)
  end
end
