require 'rails_helper'

RSpec.describe SchoolMailer, type: :mailer do
  describe 'add_partner' do
    let(:user) { create(:user, authentication_token: Devise.friendly_token) }
    let(:school_name) { 'Wildflower Test School' }
    let(:mail) { SchoolMailer.add_partner(user.id, school_name) }

    it 'renders the headers' do
      expect(mail.subject).to eq("#{ENV.fetch('APP_NAME',
                                              'My Wildflower')} - You have been added to the #{school_name} dashboard")
      expect(mail.to).to eq([user.email])
      expect(mail.cc).to eq(['support@wildflowerschools.org'])
      expect(mail.bcc).to eq(['support@wildflowerschools.org'])
      expect(mail.from).to eq(['platform@email.wildflowerschools.org'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match(school_name)
      expect(mail.body.encoded).to match(user.authentication_token)
      expect(mail.body.encoded).to match(ENV.fetch('FRONTEND_URL', nil))
    end
  end
end
