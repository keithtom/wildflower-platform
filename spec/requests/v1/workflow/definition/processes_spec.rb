require 'rails_helper'

RSpec.describe V1::Workflow::Definition::ProcessesController, type: :request do
  describe 'POST #create' do
    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }
      let(:valid_params) { { process: { version: '1.0', title: 'Test Workflow', description: 'This is a test process', position: 0 } } }

      before do
        sign_in(admin)
        post '/v1/workflow/definition/processes', params: valid_params
      end

      it 'creates a new process' do
        expect(response).to have_http_status(:success)
        expect(Workflow::Definition::Process.count).to eq(1)
      end

      it 'returns the created process as JSON' do
        process = Workflow::Definition::Process.last
        expected_json = V1::Workflow::Definition::ProcessSerializer.new(process).to_json
        expect(response.body).to eq(expected_json)
      end
    end

    context 'when not authenticated as admin' do
      let(:user) { create(:user) }
      let(:valid_params) { { process: { version: '1.0', title: 'Test Process', description: 'This is a test process' } } }

      before do
        sign_in(user)
        post '/v1/workflow/definition/processes', params: valid_params
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not create a new process' do
        expect(Workflow::Definition::Process.count).to eq(0)
      end
    end
  end

  describe 'PUT #update' do
    let!(:process) { create(:workflow_definition_process) }
    let(:valid_params) { { process: { version: '2.0', title: 'Updated Process', description: 'This is an updated process', position: 1 } } }

    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
        put "/v1/workflow/definition/processes/#{process.id}", params: valid_params
      end

      it 'updates the process' do
        process.reload
        expect(response).to have_http_status(:success)
        expect(process.version).to eq('2.0')
        expect(process.title).to eq('Updated Process')
        expect(process.description).to eq('This is an updated process')
        expect(process.position).to eq(1)
      end

      it 'returns the updated process as JSON' do
        expected_json = V1::Workflow::Definition::ProcessSerializer.new(process.reload).to_json
        expect(response.body).to eq(expected_json)
      end
    end

    context 'when not authenticated as admin' do
      let(:user) { create(:user) }

      before do
        sign_in(user)
        put "/v1/workflow/definition/processes/#{process.id}", params: valid_params
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not update the process' do
        process.reload
        expect(process.version).not_to eq('2.0')
        expect(process.title).not_to eq('Updated Process')
        expect(process.description).not_to eq('This is an updated process')
        expect(process.position).not_to eq(1)
      end
    end
  end
end