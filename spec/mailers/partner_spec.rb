require "rails_helper"

RSpec.describe PartnerMailer, type: :mailer do
  describe "invite" do
    let(:user) { build(:user, authentication_token: Devise.friendly_token) }
    let(:inviter) { build(:user, person: person) }
    let(:person) { build(:person, ssj_team: team) }
    let(:team) { build(:ssj_team) }
    let(:mail) { PartnerMailer.invite(user, inviter) }

    it "renders the headers" do
      expect(mail.subject).to eq("Welcome to the School Startup Journey!")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["platform@wildflowerschools.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("School Startup Journey")
      expect(mail.body.encoded).to match(inviter.name)
      expect(mail.body.encoded).to match(user.authentication_token)
    end
  end
end
