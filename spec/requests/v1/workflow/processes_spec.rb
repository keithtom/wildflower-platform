require 'rails_helper'

RSpec.describe "V1::Workflow::Processes", type: :request do
  let(:headers) { {'ACCEPT' => 'application/json'} }
  let(:person) { create(:person) }
  let(:workflow_definition) { Workflow::Definition::Workflow.create!(version: "1.0", name: "Visioning", description: "Imagine the school of your dreams") }
  let(:workflow) { Workflow::Instance::Workflow.create!(definition: workflow_definition) }
  let(:process_definition) { Workflow::Definition::Process.create!(title: "file taxes", description: "pay taxes to the IRS", effort: 2) }
  let(:process) { Workflow::Instance::Process.create!(definition: process_definition, workflow: workflow) }

  describe "PUT /v1/processes/6823-2341/assign" do
    it "succeeds" do
      put "/v1/workflow/processes/#{process.external_identifier}/assign", headers: headers,
        params: { process: { assignee_id: person.external_identifier } }
      expect(response).to have_http_status(:success)
      expect(process.reload.assignee).to eq(person)
    end
  end

  describe "GET /v1/processes/6823-2341" do
    it "succeeds" do
      get "/v1/workflow/processes/#{process.external_identifier}", headers: headers
      expect(response).to have_http_status(:success)
      expect(json_response["data"]).to have_type(:process).and have_attribute(:status)
    end
  end
end
