require 'rails_helper'

RSpec.describe LoginMailer, type: :mailer do
  describe 'login' do
    let(:user) { build(:user, authentication_token: Devise.friendly_token) }
    let(:mail) { LoginMailer.login(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Login to My Wildflower Platform')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["platform@email.wildflowerschools.org"])
    end

    it 'renders the login url' do
      expect(mail.body.encoded).to match(user.authentication_token)
    end
  end
end