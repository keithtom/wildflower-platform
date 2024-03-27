require 'rails_helper'

RSpec.describe V1::Workflow::Definition::WorkflowsController, type: :request do
  describe 'GET #index' do
    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
      end

      it 'returns a success response' do
        get '/v1/workflow/definition/workflows'
        expect(response).to have_http_status(:success)
      end

      it 'returns all workflows as JSON' do
        workflow1 = create(:workflow_definition_workflow, name: "basic 1", version: "v0")
        workflow2 = create(:workflow_definition_workflow, name: "basic 1", version: "v1")
        workflow3 = create(:workflow_definition_workflow, name: "charter 1", version: "v0")
        workflows = [workflow2, workflow3]
        get '/v1/workflow/definition/workflows'
        expected_json = V1::Workflow::Definition::WorkflowSerializer.new(workflows, { include: ['processes'] }).to_json
        expect(response.body).to eq(expected_json)
      end
    end

    context 'when not authenticated as admin' do
      let(:user) { create(:user) }

      before do
        sign_in(user)
      end

      it 'returns unauthorized status' do
        get '/v1/workflow/definition/workflows'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET #show' do
    let(:workflow) { create(:workflow_definition_workflow) }

    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
      end

      it 'returns a success response' do
        get "/v1/workflow/definition/workflows/#{workflow.id}"
        expect(response).to have_http_status(:success)
      end

      it 'returns the workflow as JSON' do
        get "/v1/workflow/definition/workflows/#{workflow.id}"
        expected_json = V1::Workflow::Definition::WorkflowSerializer.new(workflow, { include: ['processes'] }).to_json
        expect(response.body).to eq(expected_json)
      end
    end

    context 'when not authenticated as admin' do
      let(:user) { create(:user) }

      before do
        sign_in(user)
      end

      it 'returns unauthorized status' do
        get "/v1/workflow/definition/workflows/#{workflow.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
  describe 'POST #create' do
    let(:valid_params) { { workflow: { version: '1.0', name: 'Test Workflow', description: 'This is a test workflow' } } }

    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
        post '/v1/workflow/definition/workflows', params: valid_params
      end

      it 'creates a new workflow' do
        expect(response).to have_http_status(:success)
        expect(Workflow::Definition::Workflow.count).to eq(1)
      end

      it 'returns the created workflow as JSON' do
        workflow = Workflow::Definition::Workflow.last
        expected_json = V1::Workflow::Definition::WorkflowSerializer.new(workflow, { include: ['processes'] }).to_json
        expect(response.body).to eq(expected_json)
      end
    end

    context 'when not authenticated as admin' do
      let(:user) { create(:user) }

      before do
        sign_in(user)
        post '/v1/workflow/definition/workflows', params: valid_params
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not create a new workflow' do
        expect(Workflow::Definition::Workflow.count).to eq(0)
      end
    end
  end
  describe 'PUT #update' do
    let!(:workflow) { create(:workflow_definition_workflow) }
    let(:valid_params) { { workflow: { version: '2.0', name: 'Updated Workflow', description: 'This is an updated workflow' } } }

    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
        put "/v1/workflow/definition/workflows/#{workflow.id}", params: valid_params
      end

      it 'updates the workflow' do
        workflow.reload
        expect(response).to have_http_status(:success)
        expect(workflow.version).to eq('2.0')
        expect(workflow.name).to eq('Updated Workflow')
        expect(workflow.description).to eq('This is an updated workflow')
      end

      it 'returns the updated workflow as JSON' do
        expected_json = V1::Workflow::Definition::WorkflowSerializer.new(workflow.reload, { include: ['processes'] }).to_json
        expect(response.body).to eq(expected_json)
      end
    end

    context 'when not authenticated as admin' do
      let(:user) { create(:user) }

      before do
        sign_in(user)
        put "/v1/workflow/definition/workflows/#{workflow.id}", params: valid_params
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not update the workflow' do
        workflow.reload
        expect(workflow.version).not_to eq('2.0')
        expect(workflow.name).not_to eq('Updated Workflow')
        expect(workflow.description).not_to eq('This is an updated workflow')
      end
    end
  end

  describe 'POST #add_process' do
    let(:admin) { create(:user, :admin) }
    let(:workflow) { create(:workflow_definition_workflow) }
    let(:prerequisite) { create(:workflow_definition_process) }
    let(:process_params) { 
      { 
        process: { 
          version: '1.0', 
          title: 'Test Workflow', 
          description: 'This is a test process', 
          steps_attributes: [
            { 
              title: 'Step 1', description: 'This is step 1', kind: Workflow::Definition::Step::DECISION, completion_type: Workflow::Definition::Step::ONE_PER_GROUP, min_worktime: 5, max_worktime: 10,
              decision_options_attributes: [{description: "option 1"}, {description: "option 2"}],
              documents_attributes: [{title: "document title", link: "www.example.com"}]
            },
            { title: 'Step 2', description: 'This is step 2', kind: Workflow::Definition::Step::DEFAULT, completion_type: Workflow::Definition::Step::ONE_PER_GROUP }
          ],
          workable_dependencies_attributes: [
            { workflow_id: workflow.id, prerequisite_workable_type: "Workflow::Definition::Process", prerequisite_workable_id: prerequisite.id},
          ]
        } 
      } 
    }

    before do
      sign_in(admin)
    end

    context 'when the workflow is published' do
      before do
        workflow.update(published_at: DateTime.now)
        post "/v1/workflow/definition/workflows/#{workflow.id}/add_process", params: process_params
      end

      it 'returns an error response' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Cannot add processes to a published workflow. Please create a new version to continue.')
      end
    end

    context 'when the workflow is not published' do
      before do
        post "/v1/workflow/definition/workflows/#{workflow.id}/add_process", params: process_params
      end

      it 'creates a new process and associates it with the workflow' do
        expect(response).to have_http_status(:success)
        expect(Workflow::Definition::Process.count).to eq(2) # 2 because we also created a prerequisite in the test setup
        expect(Workflow::Definition::SelectedProcess.count).to eq(1)
        expect(Workflow::Definition::Step.count).to eq(2)
        expect(Workflow::DecisionOption.count).to eq(2)
        expect(Document.count).to eq(1)
        expect(Workflow::Definition::Dependency.count).to eq(1)

        process = Workflow::Definition::Process.last
        expect(workflow.processes.last).to eq(process)

        expected_json = V1::Workflow::Definition::ProcessSerializer.new(process, { include: ['steps', 'selected_processes', 'prerequisites'] }).to_json
        # pretty_json = JSON.pretty_generate(JSON.parse(expected_json))
        # puts pretty_json
        expect(response.body).to eq(expected_json)
      end
    end
  end
end