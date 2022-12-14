require 'rails_helper'

RSpec.describe "V1::Workflow::Workflows", type: :request do
  let(:headers) { {'ACCEPT' => 'application/json'} }
  let(:workflow) { create(:workflow_instance_workflow) }
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe "GET /v1/workflow/workflows/:id" do
    it "succeeds" do
      get "/v1/workflow/workflows/#{workflow.external_identifier}", headers: headers
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /v1/workflow/workflows/:id/resources" do
    before do
      album_process = create(:workflow_instance_process, workflow: workflow)
      album_process.definition.category_list.add("Album Advice & Affiliation")
      album_process.definition.save!

      3.times do
        step_definition = create(:workflow_definition_step, process: album_process.definition)
        step = create(:workflow_instance_step, process: album_process, definition: step_definition)
      end

      finance_process = create(:workflow_instance_process, workflow: workflow)
      finance_process.definition.category_list.add("Finance")
      finance_process.definition.save!

      3.times do
        step_definition = create(:workflow_definition_step, process: finance_process.definition)
        step = create(:workflow_instance_step, process: finance_process, definition: step_definition)
      end
    end

    it "succeeds" do
      get "/v1/workflow/workflows/#{workflow.external_identifier}/resources", headers: headers
      expect(response).to have_http_status(:success)
      expect(json_response["data"].count).to be(6)
      expect(json_response["data"].first).to have_attribute("categories")
    end
  end
end
