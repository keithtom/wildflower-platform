require 'rails_helper'

RSpec.describe Person, type: :model do
  describe "#update_ssj_team_member_status" do
    let(:person) { create(:person) }
    let(:ssj_team) { create(:ssj_team) }
    let!(:ssj_team_member) { create(:ssj_team_member, person: person, ssj_team: ssj_team, status: "invited") }

    context "when is_onboarded is changed to true" do
      it "updates the status of ssj_team_members to active" do
        person.update(is_onboarded: true)
        ssj_team_member.reload
        expect(ssj_team_member.status).to eq("active")
      end
    end

    context "when is_onboarded is changed to false" do
      it "does not update the status of ssj_team_members" do
        person.update(is_onboarded: false)
        ssj_team_member.reload
        expect(ssj_team_member.status).to eq("invited")
      end
    end
  end
end