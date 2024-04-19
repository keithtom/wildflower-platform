require 'rails_helper'

RSpec.describe 'V1::Workflow::Definition::Dependency', type: :request do
  describe 'DELETE #destroy' do
    let(:admin) { create(:user, :admin) }
    let!(:dependency) { Workflow::Definition::Dependency.create(
      workflow: create(:workflow_definition_workflow),
      workable: create(:workflow_definition_process),
      prerequisite_workable: create(:workflow_definition_process)
    )}

    before do
      sign_in(admin)
    end

    it 'deletes the dependency' do
      expect {
        delete "/v1/workflow/definition/dependencies/#{dependency.id}"
      }.to change(Workflow::Definition::Dependency, :count).by(-1)
    end

    it 'returns a success message' do
      delete "/v1/workflow/definition/dependencies/#{dependency.id}"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq({ 'message' => 'Successfully deleted dependency' })
    end
  end
end