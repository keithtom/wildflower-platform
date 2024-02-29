require 'rails_helper'

RSpec.describe V1::Workflow::Definition::ProcessesController, type: :request do
   describe 'GET #index' do
    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
      end

      it 'returns a success response' do
        get '/v1/workflow/definition/processes'
        expect(response).to have_http_status(:success)
      end

      it 'returns all processes as JSON' do
        processes = create_list(:workflow_definition_process, 3)
        get '/v1/workflow/definition/processes'
        expected_json = V1::Workflow::Definition::ProcessSerializer.new(processes).to_json
        expect(response.body).to eq(expected_json)
      end
    end

    context 'when not authenticated as admin' do
      let(:user) { create(:user) }

      before do
        sign_in(user)
      end

      it 'returns unauthorized status' do
        get '/v1/workflow/definition/processes'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET #show' do
    let(:process) { create(:workflow_definition_process) }

    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
      end

      it 'returns a success response' do
        get "/v1/workflow/definition/processes/#{process.id}"
        expect(response).to have_http_status(:success)
      end

      it 'returns the process as JSON' do
        get "/v1/workflow/definition/processes/#{process.id}"
        expected_json = V1::Workflow::Definition::ProcessSerializer.new(process).to_json
        expect(response.body).to eq(expected_json)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:process) { create(:workflow_definition_process) }
    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
      end

      it 'returns a success response' do
        delete "/v1/workflow/definition/processes/#{process.id}"
        expect(response).to have_http_status(:success)
      end

      it 'deletes the process' do
        expect {
          delete "/v1/workflow/definition/processes/#{process.id}"
        }.to change(Workflow::Definition::Process, :count).by(-1)
      end

      it 'returns a success message' do
        delete "/v1/workflow/definition/processes/#{process.id}"
        expect(response.body).to eq({ message: 'Process deleted successfully' }.to_json)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) { 
      { 
        process: { 
          version: '1.0', 
          title: 'Test Workflow', 
          description: 'This is a test process', 
          position: 0,
          steps_attributes: [
            { 
              title: 'Step 1', description: 'This is step 1', kind: Workflow::Definition::Step::DECISION, completion_type: Workflow::Definition::Step::ONE_PER_GROUP, 
              decision_options_attributes: [{description: "option 1"}, {description: "option 2"}],
              documents_attributes: [{title: "document title", link: "www.example.com"}]
            },
            { title: 'Step 2', description: 'This is step 2', kind: Workflow::Definition::Step::DEFAULT, completion_type: Workflow::Definition::Step::ONE_PER_GROUP }
          ]
        } 
      } 
    }

    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
        post '/v1/workflow/definition/processes', params: valid_params
      end

      it 'creates a new process' do
        expect(response).to have_http_status(:success)
        expect(Workflow::Definition::Process.count).to eq(1)
        expect(Workflow::Definition::Step.count).to eq(2)
        expect(Workflow::DecisionOption.count).to eq(2)
        expect(Document.count).to eq(1)
      end

      it 'returns the created process as JSON' do
        process = Workflow::Definition::Process.last
        expected_json = V1::Workflow::Definition::ProcessSerializer.new(process).to_json
        expect(response.body).to eq(expected_json)
      end
    end

    context 'when not authenticated as admin' do
      let(:user) { create(:user) }

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