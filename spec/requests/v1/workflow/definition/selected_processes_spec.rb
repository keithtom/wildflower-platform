require 'rails_helper'

RSpec.describe "V1::Workflow::Definition::SelectedProcesses", type: :request do
  let(:admin) { create(:user, :admin) }
  describe "POST /v1/workflow/definition/selected_processes/:id/revert" do
    let(:previous_version) { create(:selected_process, state: 'initialized') }
    let(:selected_process) { create(:selected_process, state: 'upgraded', previous_version: previous_version) }

    before do
      sign_in(admin)
    end

    it "reverts the selected process" do
      put "/v1/workflow/definition/selected_processes/#{selected_process.id}/revert"

      expect(response).to have_http_status(200)
      expect(selected_process.reload).to be_replicated
      expect(selected_process.process_id).to eq(previous_version.process_id)
    end
  end

  describe 'PUT /v1/workflow/definition/selected_processes/:selected_process_id' do
    let(:selected_process) { create(:selected_process, workflow: workflow) }
    let(:workflow) { create(:workflow_definition_workflow, published_at: nil) }

    before do
      sign_in(admin)
    end

    context 'when selected process is replicated and workflow is not published' do
      before do
        selected_process.update(state: 'replicated')
        put "/v1/workflow/definition/selected_processes/#{selected_process.id}", params: { selected_process: { position: 200 } }
      end

      it 'updates the selected process' do
        expect(response).to have_http_status(:success)
        expect(selected_process.reload.position).to eq(200)
      end

      it 'repositions the selected process' do
        expect(selected_process.reload.state).to eq('repositioned')
      end

      it 'returns the updated selected process as JSON' do
        json_response = JSON.parse(response.body)
        expect(json_response['data']['id']).to eq(selected_process.id.to_s)
        expect(json_response['data']['attributes']['position']).to eq(200)
      end
    end

    context 'when selected process is in added state' do
      before do
        selected_process.update(state: 'added')
        put "/v1/workflow/definition/selected_processes/#{selected_process.id}", params: { selected_process: { position: 200 } }
      end

      it 'updates the selected process' do
        expect(response).to have_http_status(:success)
        expect(selected_process.reload.position).to eq(200)
        expect(selected_process.repositioned?).to be_truthy
      end
    end

    context 'when selected process is in upgraded state' do
      before do
        selected_process.update(state: 'upgraded')
        put "/v1/workflow/definition/selected_processes/#{selected_process.id}", params: { selected_process: { position: 200 } }
      end

      it 'updates the selected process' do
        expect(response).to have_http_status(:success)
        expect(selected_process.reload.position).to eq(200)
        expect(selected_process.repositioned?).to be_falsey
        expect(selected_process.upgraded?).to be_truthy
      end
    end

    context 'when selected process has already been repositioned once' do
      before do
        selected_process.update(state: 'repositioned')
        put "/v1/workflow/definition/selected_processes/#{selected_process.id}", params: { selected_process: { position: 200 } }
      end

      it 'updates the selected process' do
        expect(response).to have_http_status(:success)
        expect(selected_process.reload.position).to eq(200)
        expect(selected_process.repositioned?).to be_truthy
      end
    end

    context 'when workflow is published' do
      before do
        workflow.update(published_at: DateTime.now)
        selected_process.update(state: 'replicated')
        put "/v1/workflow/definition/selected_processes/#{selected_process.id}", params: { selected_process: { position: 200 } }
      end

      it 'returns an error message' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('workflow published, please change position using other endpoint')
      end
    end
  end
end