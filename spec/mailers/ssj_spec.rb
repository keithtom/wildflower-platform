require "rails_helper"

RSpec.describe SSJMailer, type: :mailer do
  describe "invite" do
    let(:user) { build(:user, authentication_token: Devise.friendly_token) }
    let(:inviter) { build(:user, person: person) }
    let(:person) { build(:person) }
    let(:team) { create(:ssj_team) }
    let(:mail) { SSJMailer.invite(user, inviter) }

    before do
      SSJ::TeamMember.create(person: person, ssj_team: team, status: SSJ::TeamMember::ACTIVE, role: SSJ::TeamMember::PARTNER)
      SSJ::TeamMember.create(person_id: team.ops_guide_id, ssj_team: team, status: SSJ::TeamMember::ACTIVE, role: SSJ::TeamMember::OPS_GUIDE)
      SSJ::TeamMember.create(person_id: team.regional_growth_lead_id, ssj_team: team, status: SSJ::TeamMember::ACTIVE, role: SSJ::TeamMember::RGL)
    end

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
