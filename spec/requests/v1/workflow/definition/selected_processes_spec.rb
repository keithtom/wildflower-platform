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

    context 'when called with valid params' do
      before do
        selected_process.update(state: 'replicated')
        put "/v1/workflow/definition/selected_processes/#{selected_process.id}", params: { selected_process: { position: 200 } }
      end

      it 'updates the selected process' do
        expect(response).to have_http_status(:success)
        expect(selected_process.reload.position).to eq(200)
      end
    end

    context 'when error is raised' do
      let(:position) { 200.5 }
      before do
        put "/v1/workflow/definition/selected_processes/#{selected_process.id}", params: { selected_process: { position: position } }
      end

      it 'returns a success' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('new position must be an integer')
      end
    end
  end
end