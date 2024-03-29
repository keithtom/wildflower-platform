require "rails_helper"

RSpec.describe SSJMailer, type: :mailer do
  describe "invite" do
    let(:user) { create(:user, authentication_token: Devise.friendly_token) }
    let(:ops_guide) { create(:user) }
    let(:mail) { SSJMailer.invite(user.id, ops_guide.id) }

    it "renders the headers" do
      expect(mail.subject).to eq("Welcome to the School Startup Journey!")
      expect(mail.to).to eq([user.email])
      expect(mail.cc).to eq([ops_guide.email])
      expect(mail.from).to eq(["platform@email.wildflowerschools.org"])
      expect(mail.reply_to).to eq(["support@wildflowerschools.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("School Startup Journey")
      expect(mail.body.encoded).to match(user.authentication_token)
    end
  end

  describe "invite_partner" do
    let(:user) { create(:user, authentication_token: Devise.friendly_token) }
    let(:inviter) { create(:user, person: person) }
    let(:person) { create(:person) }
    let(:team) { create(:ssj_team) }
    let(:mail) { SSJMailer.invite_partner(user.id, inviter.id, team.ops_guide_id) }

    before do
      SSJ::TeamMember.create(person: person, ssj_team: team, status: SSJ::TeamMember::ACTIVE, role: SSJ::TeamMember::PARTNER)
      SSJ::TeamMember.create(person_id: team.ops_guide_id, ssj_team: team, status: SSJ::TeamMember::ACTIVE, role: SSJ::TeamMember::OPS_GUIDE)
      SSJ::TeamMember.create(person_id: team.regional_growth_lead_id, ssj_team: team, status: SSJ::TeamMember::ACTIVE, role: SSJ::TeamMember::RGL)
    end

    it "renders the headers" do
      expect(mail.subject).to eq("Welcome to the School Startup Journey!")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["platform@email.wildflowerschools.org"])
      expect(mail.cc).to eq([team.ops_guide.email, "support@wildflowerschools.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("School Startup Journey")
      expect(mail.body.encoded).to match(inviter.name)
      expect(mail.body.encoded).to match(user.authentication_token)
    end
  end

  describe "invite" do
    let(:user) { create(:user, authentication_token: Devise.friendly_token) }
    let(:ops_guide) { create(:user) }
    let(:mail) { SSJMailer.invite(user.id, ops_guide.id) }

    it "renders the headers" do
      expect(mail.subject).to eq("Welcome to the School Startup Journey!")
      expect(mail.to).to eq([user.email])
      expect(mail.cc).to eq([ops_guide.email])
      expect(mail.from).to eq(["platform@email.wildflowerschools.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("School Startup Journey")
      expect(mail.body.encoded).to match(user.authentication_token)
    end
  end

  describe 'invite ops guide to new dashboard' do
    let(:user) { build(:user, authentication_token: Devise.friendly_token) }
    let(:team) { create(:ssj_team) }
    let(:mail) { SSJMailer.invite_ops_guide(user, team) }

    before do
      SSJ::TeamMember.create(person: build(:person), ssj_team: team, status: SSJ::TeamMember::ACTIVE, role: SSJ::TeamMember::PARTNER)
      SSJ::TeamMember.create(person: build(:person), ssj_team: team, status: SSJ::TeamMember::ACTIVE, role: SSJ::TeamMember::PARTNER)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq('SSJ Dashboard: You have a new team!')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["platform@email.wildflowerschools.org"])
    end

    it 'renders the auth token' do
      expect(mail.body.encoded).to match(user.authentication_token)
    end
  end
end
