require 'rails_helper'

RSpec.describe "V1::Ssj::Dashboard", type: :request do
  let(:headers) { {'ACCEPT' => 'application/json'} }
  let(:person) { create(:person) }
  let(:user) { create(:user, person_id: person.id) }
  let!(:step) { create(:workflow_instance_step) }
  let(:workflow) { step.process.workflow }
  let(:expected_start_date) { Date.today + 7.days }
  let(:partner) { create(:person) }
  let(:partner_user_account) { create(:user, person_id: partner.id) }

  before do
    sign_in(user)
    team = SSJ::Team.new(expected_start_date: expected_start_date)
    team.workflow = workflow
    team.people << person
    team.save!
  end

  describe "GET /v1/ssj/dashboard/resources" do
    before do
      p = step.definition.process
      p.category_list << "finance"
      p.save
    end

    it "succeeds" do
      get "/v1/ssj/dashboard/resources", headers: headers
      expect(response).to have_http_status(:success)
      expect(json_response.first["finance"]).to_not be_nil
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
    let(:workflow) { create(:workflow_instance_workflow) }
    let(:new_start_date) { "2023-03-01" }

    it "succeeds" do
      put "/v1/ssj/dashboard/team", headers: headers, params: { team: { expected_start_date: new_start_date }}
      expect(response).to have_http_status(:success)
      expect(json_response["expectedStartDate"]).to eq(new_start_date)
      expect(user.person.ssj_team.reload.expected_start_date.to_formatted_s("yyyy-mm-dd")).to eq(new_start_date)
    end
  end
end
