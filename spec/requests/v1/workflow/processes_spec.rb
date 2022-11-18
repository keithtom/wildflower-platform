require 'rails_helper'

RSpec.describe "V1::Workflow::Processes", type: :request do
  let(:headers) { {'ACCEPT' => 'application/json'} }
  let(:person) { create(:person) }
  let (:workflow_definition_workflow) { Workflow::Definition::Workflow.create!(version: "1.0", name: "Visioning", description: "Imagine the school of your dreams") }
  let (:workflow_instance_workflow) { Workflow::Instance::Workflow.create!(workflow_definition_workflow_id: workflow_definition_workflow.id) }
  let(:process_definition) { Workflow::Definition::Process.create!(title: "file taxes", description: "pay taxes to the IRS", effort: 2) }
  let(:process) { Workflow::Instance::Process.create!(workflow_definition_process_id: process_definition.id, workflow_instance_workflow_id: workflow_instance_workflow.id) }

  describe "PUT /v1/processes/6823-2341/assign" do
    it "succeeds" do
      put "/v1/workflow/processes/#{process.external_identifier}/assign", headers: headers,
        params: { process: { assignee_id: person.external_identifier } }
      expect(response).to have_http_status(:success)
      expect(process.reload.assignee).to eq(person)
    end
  end
end
