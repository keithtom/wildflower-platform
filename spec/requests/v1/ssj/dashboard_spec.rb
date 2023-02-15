require 'rails_helper'

RSpec.describe "V1::Ssj::Dashboard", type: :request do
  let(:headers) { {'ACCEPT' => 'application/json'} }
  let(:person) { create(:person) }
  let(:user) { create(:user, person_id: person.id) }
  let!(:step) { create(:workflow_instance_step) }
  let(:workflow) { step.process.workflow }

  before do
    sign_in(user)
    team = SSJ::Team.new
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
      get "/v1/ssj/dashboard/resources", headers: headers, params: { workflow_id: step.process.workflow.external_identifier }
      expect(response).to have_http_status(:success)
      expect(json_response["finance"]).to_not be_nil
    end
  end

  describe "GET /v1/ssj/dashboard/team" do
    let(:workflow) { create(:workflow_instance_workflow) }

    it "succeeds" do
      get "/v1/ssj/dashboard/team", headers: headers
      expect(response).to have_http_status(:success)
      expect(json_response["hasPartner"]).to be false
    end
  end
end
