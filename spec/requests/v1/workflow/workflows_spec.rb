require 'rails_helper'

RSpec.describe "V1::Workflow::Workflows", type: :request do
  let(:headers) { {'ACCEPT' => 'application/json'} }
  let(:workflow) { create(:workflow_instance_workflow) }

  describe "GET /v1/workflow/workflows/:id" do
    it "succeeds" do
      get "/v1/workflow/workflows/#{workflow.external_identifier}", headers: headers
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /v1/workflow/workflows/:id/resources" do
    let(:process) { create(:workflow_instance_process, workflow: workflow) }

    before do
      3.times do
        create(:workflow_instance_step, process: process)
      end
    end

    it "succeeds" do
      get "/v1/workflow/workflows/#{workflow.external_identifier}/resources", headers: headers
      expect(response).to have_http_status(:success)
      expect(json_response["data"].count).to be(3)
    end
  end
end
