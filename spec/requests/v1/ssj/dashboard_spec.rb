require 'rails_helper'

RSpec.describe "V1::SSJ::Dashboard", type: :request do
  let(:headers) { {'ACCEPT' => 'application/json'} }
  let(:person) { create(:person) }
  let(:user) { create(:user, person_id: person.id) }
  let!(:step) { create(:workflow_instance_step) }
  let(:workflow) { step.process.workflow }
  let(:expected_start_date) { Date.today + 7.days }
  let(:phase) { Workflow::Definition::Process::PHASES.first }

  before do
    sign_in(user)
    team = SSJ::Team.new(expected_start_date: expected_start_date)
    team.workflow = workflow
    team.save!
    SSJ::TeamMember.create!(ssj_team: team, person: person, status: SSJ::TeamMember::ACTIVE, role: SSJ::TeamMember::PARTNER)
    p = step.definition.process
    p.category_list << "finance"
    p.category_list << "Human Resources"
    p.save!
    step.assignments.create!(assignee: person)
    p.phase_list << phase
    p.save!
  end

  describe "GET /v1/ssj/dashboard/assigned_steps" do
    it "succeeds" do
      get "/v1/ssj/dashboard/assigned_steps", headers: headers
      expect(response).to have_http_status(:success)
      expect(json_response['data'][0]).to have_type('stepAssignment')
      expect(json_response['data'][0]).to have_attribute("assignedAt")
      expect(json_response['data'][0]).to have_attribute("completedAt")
      expect(json_response['data'][0]).to have_relationships('assignee', 'step')
      expect(json_response['included']).to include(have_type('person'))
      expect(json_response['included']).to include(have_type('step'))
      expect(json_response['included']).to include(have_type('document'))
      expect(json_response['included']).to include(have_type('process'))
    end
  end

  describe "GET /v1/ssj/dashboard/resources" do
    it "succeeds" do
      get "/v1/ssj/dashboard/resources", headers: headers
      expect(response).to have_http_status(:success)
      expect(json_response["by_category"][1]["finance"]).to_not be_nil
      expect(json_response["by_category"][4]["human_resources"]).to_not be_nil
      expect(json_response["by_category"][4]["human_resources"]).to_not be_empty
      expect(json_response["by_phase"].first[phase]).to_not be_nil
    end
  end

  describe "GET /v1/ssj/dashboard/team" do
    let(:workflow) { create(:workflow_instance_workflow) }

    it "succeeds" do
      get "/v1/ssj/dashboard/team", headers: headers
      expect(response).to have_http_status(:success)
      expect(json_response["hasPartner"]).to be false
      expect(json_response["expectedStartDate"]).to eq(expected_start_date.to_formatted_s("yyyy-mm-dd"))
    end
  end

  describe "PUT /v1/ssj/dashboard/team" do
    let(:new_start_date) { "2023-03-01" }

    it "succeeds" do
      put "/v1/ssj/dashboard/team", headers: headers, params: { team: { expected_start_date: new_start_date }}
      expect(response).to have_http_status(:success)
      expect(json_response["expectedStartDate"]).to eq(new_start_date)
      ssj_team = SSJ::TeamMember.find_by(person_id: user.person_id).ssj_team
      expect(ssj_team.reload.expected_start_date.to_formatted_s("yyyy-mm-dd")).to eq(new_start_date)
    end
  end

  describe "PUT /v1/ssj/dashboard/invite_partner" do
    let(:email) { Faker::Internet.unique.email  }

    it "succeeds" do
      put "/v1/ssj/dashboard/invite_partner", headers: headers, params: {
        person: {
          email: email, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, primary_language: "English",
          race_ethnicity_other: "Asian, White", lgbtqia: true, gender: "Gender Non-Conforming", pronouns: "They/Them/Theirs",
          household_income: "Middle income", address_attributes: {city: 'Boston', state: 'Massachusetts'}
        }
      }
      expect(response).to have_http_status(:success)
      expect(json_response["hasPartner"]).to eq(true)
      person = user.person
      team = person.ssj_team
      expect(SSJ::TeamMember.where(ssj_team_id: team.id, status: SSJ::TeamMember::INVITED)).to_not be_empty
    end
  end
end
