# Preview all emails at http://localhost:3000/rails/mailers/network
class NetworkPreview < ActionMailer::Preview
  def remind_login
    NetworkMailer.remind_login(User.first)
  end

  def remind_login2
    NetworkMailer.remind_login2(User.first.id)
  end
end
