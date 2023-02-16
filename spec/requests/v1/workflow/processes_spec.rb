require 'rails_helper'

RSpec.describe "V1::Workflow::Processes", type: :request do
  let(:headers) { {'ACCEPT' => 'application/json'} }
  let(:person) { create(:person) }
  let(:workflow_definition) { Workflow::Definition::Workflow.create!(version: "1.0", name: "Visioning", description: "Imagine the school of your dreams") }
  let(:workflow) { Workflow::Instance::Workflow.create!(definition: workflow_definition) }
  let(:process_definition) { Workflow::Definition::Process.create!(title: "file taxes", description: "pay taxes to the IRS", effort: 2) }
  let!(:process) { Workflow::Instance::Process.create!(definition: process_definition, workflow: workflow) }
  let(:user) { create(:user, person_id: person.id) }
  let!(:assigned_step) { create(:workflow_instance_step_manual, process_id: process.id, assignee_id: user.person_id) }

  before do
    sign_in(user)
  end

  describe "GET /v1/processes/6823-2341" do
    it "succeeds" do
      get "/v1/workflow/processes/#{process.external_identifier}", headers: headers
      expect(response).to have_http_status(:success)
      expect(json_response["data"]).to have_type(:process).and have_attribute(:status)
      expect(json_response["data"]).to have_type(:process).and have_attribute(:stepsCount)
      expect(json_response["data"]).to have_type(:process).and have_attribute(:completedStepsCount)
    end
  end

  describe "GET /v1/workflow/workflows/6823-2341/processes with steps only assigned to current user" do
    let!(:unassigned_step) { create(:workflow_instance_step_manual, process_id: process.id) }

    it "succeeds" do
      get "/v1/workflow/workflows/#{workflow.external_identifier}/processes?self_assigned=true", headers: headers
      expect(response).to have_http_status(:success)
      expect(json_response["data"][0]).to have_type(:process).and have_attribute(:status)
      expect(json_response["data"][0]).to have_type(:process).and have_attribute(:stepsCount)
      expect(json_response["data"][0]).to have_type(:process).and have_attribute(:completedStepsCount)
      steps = json_response["data"][0]["relationships"]["steps"]["data"]
      expect(steps.length).to eq(1)
      expect(steps[0]["id"]).to_not eq(unassigned_step.external_identifier)
      expect(steps[0]["id"]).to eq(assigned_step.external_identifier)
    end
  end
end
