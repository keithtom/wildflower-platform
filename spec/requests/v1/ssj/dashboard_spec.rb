require 'rails_helper'

RSpec.describe "V1::SSJ::Dashboard", type: :request do
  let(:headers) { {'ACCEPT' => 'application/json'} }
  let(:person) { create(:person) }
  let(:user) { create(:user, person_id: person.id) }
  let!(:step) { create(:workflow_instance_step) }
  # let!(:decision_step) { create(:workflow_instance_step, :decision) }
  let(:workflow) { step.process.workflow }
  let(:expected_start_date) { Date.today + 7.days }
  let(:phase) { SSJ::Phase::PHASES.first }

  before do
    sign_in(user)
    team = SSJ::Team.new(expected_start_date: expected_start_date)
    team.workflow = workflow
    team.save!
    SSJ::TeamMember.create!(ssj_team: team, person: person, status: SSJ::TeamMember::ACTIVE, role: SSJ::TeamMember::PARTNER)
    p = step.definition.process
    p.category_list << "Finance"
    p.category_list << "Human Resources"
    p.category_list << "unknown category"
    p.save!
    step.assignments.create!(assignee: person)
    p.phase_list << phase
    p.save!
  end

  describe "GET /v1/ssj/dashboard/resources" do
    it "succeeds" do
      get "/v1/ssj/dashboard/resources", headers: headers
      expect(response).to have_http_status(:success)
      expect(json_response["by_category"][1]["Finance"]).to_not be_nil
      expect(json_response["by_category"][4]["Human Resources"]).to_not be_nil
      expect(json_response["by_category"][4]["Human Resources"]).to_not be_empty
      expect(json_response["by_phase"].first[phase]).to_not be_nil
    end
  end
end
