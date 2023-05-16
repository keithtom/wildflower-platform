require 'rails_helper'

RSpec.describe "V1::Workflow::Processes", type: :request do
  let(:headers) { {'ACCEPT' => 'application/json'} }
  let(:person) { create(:person) }
  let(:workflow_definition) { create(:workflow_definition_workflow) }
  let(:workflow) { Workflow::Instance::Workflow.create!(definition: workflow_definition) }
  let(:process_definition) { Workflow::Definition::Process.create!(title: "file taxes", description: "pay taxes to the IRS") }
  let!(:process) { Workflow::Instance::Process.create!(definition: process_definition, workflow: workflow) }
  let(:user) { create(:user, person_id: person.id) }
  let!(:assigned_step) { create(:workflow_instance_step_manual, process_id: process.id) }
  let!(:assignment) { create(:workflow_instance_step_assignment, step: assigned_step, assignee: user.person)}  

  before do
    sign_in(user)
  end

  describe "GET /v1/processes/6823-2341" do
    it "succeeds" do
      Bullet.enable = false
      get "/v1/workflow/processes/#{process.external_identifier}", headers: headers
      expect(response).to have_http_status(:success)
      expect(json_response["data"]).to have_type(:process).and have_attribute(:status)
      expect(json_response["data"]).to have_type(:process).and have_attribute(:stepsCount)
      expect(json_response["data"]).to have_type(:process).and have_attribute(:completedStepsCount)
      step_obj = json_response["included"].select{|obj| obj["type"] == "step"}.last
      Bullet.enable = true
    end
  end
end
