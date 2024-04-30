require 'rails_helper'

RSpec.describe "V1::Workflow::Definition::SelectedProcesses", type: :request do
  describe "POST /v1/workflow/definition/selected_processes/:id/revert" do
    let(:admin) { create(:user, :admin) }
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
end