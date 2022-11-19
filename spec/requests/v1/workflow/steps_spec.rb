require 'rails_helper'

RSpec.describe "V1::Workflow::Steps", type: :request do
  let (:workflow_definition) { Workflow::Definition::Workflow.create!(version: "1.0", name: "Visioning", description: "Imagine the school of your dreams") }
  let (:workflow) { Workflow::Instance::Workflow.create!(definition: workflow_definition) }
  let(:process_definition) { Workflow::Definition::Process.create!(title: "file taxes", description: "pay taxes to the IRS", effort: 2) }
  let(:process) { Workflow::Instance::Process.create!(definition: process_definition, workflow: workflow) }
  let(:step_definition) { Workflow::Definition::Step.create!(process: process_definition, title: "hire accountant") }
  let(:step) { Workflow::Instance::Step.create!(process: process, definition: step_definition) }
  let(:headers) { {'ACCEPT' => 'application/json'} }

  describe "GET /v1/workflow/processes/6982-2091/steps/bd8f-c3b2" do
    it "succeeds" do
      get "/v1/workflow/processes/#{process.external_identifier}/steps/#{step.external_identifier}", headers: headers
      expect(response).to have_http_status(:success)
      expect(json_response["data"]).to have_type(:step).and have_attribute(:title)
    end
  end

  describe "PUT /v1/workflow/processes/6982-2091/steps/bd8f-c3b2/complete" do
    it "succeeds" do
      put "/v1/workflow/processes/#{process.external_identifier}/steps/#{step.external_identifier}/complete", headers: headers
      expect(response).to have_http_status(:success)
      expect(Workflow::Instance::Step.last.completed).to be true
    end
  end

  describe "PUT /v1/workflow/processes/6982-2091/steps/bd8f-c3b2/uncomplete" do
    it "succeeds" do
      put "/v1/workflow/processes/#{process.external_identifier}/steps/#{step.external_identifier}/uncomplete", headers: headers
      expect(response).to have_http_status(:success)
      expect(Workflow::Instance::Step.last.completed).to be false
      expect(Workflow::Instance::Step.last.completed_at).to be_nil
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
