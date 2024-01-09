# Preview all emails at http://localhost:3000/rails/mailers/network
class NetworkPreview < ActionMailer::Preview
  def remind_login
    NetworkMailer.remind_login(User.first)
  end
end
