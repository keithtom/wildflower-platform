require 'rails_helper'

RSpec.describe "V1::Workflow::Steps", type: :request do
  let (:workflow_definition_workflow) { Workflow::Definition::Workflow.create!(version: "1.0", name: "Visioning", description: "Imagine the school of your dreams") }
  let (:workflow_instance_workflow) { Workflow::Instance::Workflow.create!(workflow_definition_workflow_id: workflow_definition_workflow.id) }
  let(:process_definition) { Workflow::Definition::Process.create!(title: "file taxes", description: "pay taxes to the IRS", effort: 2) }
  let(:process) { Workflow::Instance::Process.create!(workflow_definition_process_id: process_definition.id, workflow_instance_workflow_id: workflow_instance_workflow.id) }
  let(:step_definition) { Workflow::Definition::Step.create!(process_id: process_definition.id, title: "hire accountant") }
  let(:step) { Workflow::Instance::Step.create!(workflow_instance_process_id: process.id, workflow_definition_step_id: step_definition.id) }
  let(:headers) { {'ACCEPT' => 'application/json'} }

  describe "GET /v1/workflow/processes/6982-2091/steps/bd8f-c3b2" do
    it "succeeds" do
      get "/v1/workflow/processes/#{process.external_identifier}/steps/#{step.external_identifier}", headers: headers
      expect(response).to have_http_status(:success)
      expect(json_response["data"]).to have_type(:step).and have_attribute(:title)
    end
  end

  describe "PUT /v1/workflow/processes/6982-2091/steps/bd8f-c3b2" do
    it "succeeds" do
      put "/v1/workflow/processes/#{process.external_identifier}/steps/#{step.external_identifier}", headers: headers, params: { step: { completed: true } }
      expect(response).to have_http_status(:success)
      expect(Workflow::Instance::Step.last.completed).to be true
    end
  end

  describe "POST /v1/workflow/processes/6982-2091/steps" do
    it "succeeds" do
      title = "copy visioning template"
      post "/v1/workflow/processes/#{process.external_identifier}/steps", headers: headers,
        params: { step: { title: title, kind: "action" } }
      expect(response).to have_http_status(:success)
      expect(json_response["data"]).to have_type(:step).and have_attribute(:title)
      new_step = Workflow::Instance::Step.last
      expect(new_step.title).to eq(title)
      expect(new_step.position).to eq(100)
    end
  end
end
