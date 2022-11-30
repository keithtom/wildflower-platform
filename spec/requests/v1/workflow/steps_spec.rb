require 'rails_helper'

RSpec.describe "V1::Workflow::Steps", type: :request do
  let(:step) { create(:workflow_instance_step) }
  let(:process) { step.process }
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
      expect(new_step.position).to eq(2000)
    end
  end

  describe "PUT /v1/workflow/processes/6982-2091/steps/reorder" do
    context "when step is from definition," do
      it "fails" do
        put "/v1/workflow/processes/#{process.external_identifier}/steps/#{step.external_identifier}/reorder", headers: headers,
          params: { step: { position: 200 } }
        expect(response).to have_http_status(422)
      end
    end

    context "when step is manually created, reordered" do
      let(:step) { create(:workflow_instance_step_manual, position: 4000) }

      before do
        3.times do |i|
          create(:workflow_instance_step, process: process, position: 1000 * (i + 1))
        end
      end

      context "to the front of the list" do
        let(:after_position) { 0 }
        it "succeeds" do
          put "/v1/workflow/processes/#{process.external_identifier}/steps/#{step.external_identifier}/reorder", headers: headers,
            params: { step: { after_position: after_position } }
          expect(response).to have_http_status(:success)
          expect(step.reload.position).to be(500)
        end
      end
      context "to the end of the list" do
        let(:step) { create(:workflow_instance_step_manual, position: 1500) }
        let(:after_position) { 3000 }
        it "succeeds" do
          put "/v1/workflow/processes/#{process.external_identifier}/steps/#{step.external_identifier}/reorder", headers: headers,
            params: { step: { after_position: after_position } }
          expect(response).to have_http_status(:success)
          expect(step.reload.position).to be(4000)
        end
      end
      context "between two step" do
        let(:after_position) { 2000 }
        it "succeeds" do
          put "/v1/workflow/processes/#{process.external_identifier}/steps/#{step.external_identifier}/reorder", headers: headers,
            params: { step: { after_position: after_position } }
          expect(response).to have_http_status(:success)
          expect(step.reload.position).to be(2500)
        end
      end
    end
  end
end
