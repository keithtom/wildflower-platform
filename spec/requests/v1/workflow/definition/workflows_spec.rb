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
    
      context "workflow is published" do
        let!(:workflow) { create(:workflow_definition_workflow, published_at: DateTime.now) }

        it "fails" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
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

  describe 'DELETE #destroy' do
    let(:admin) { create(:user, :admin) }
    let(:workflow) { create(:workflow_definition_workflow, published_at: DateTime.now) }

    before do
      sign_in(admin)
    end

    context "published workflow" do
      let(:workflow) { create(:workflow_definition_workflow, published_at: DateTime.now) }

      it "request is unprocessable" do
        delete "/v1/workflow/definition/workflows/#{workflow.id}"
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  
    context "workflow in draft mode" do
      let(:workflow) { create(:workflow_definition_workflow) }

      it "succeeds" do
        delete "/v1/workflow/definition/workflows/#{workflow.id}"
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST #create_process' do
    let(:admin) { create(:user, :admin) }
    let(:workflow) { create(:workflow_definition_workflow) }
    let(:prerequisite) { create(:workflow_definition_process) }
    let(:process_params) { 
      { 
        process: { 
          version: '1.0', 
          title: 'Test Workflow', 
          description: 'This is a test process', 
          selected_processes_attributes: [{workflow_id: workflow.id, position: 200}],
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

  describe 'PUT #add_process' do
    let(:admin) { create(:user, :admin) }
    let(:workflow) { create(:workflow_definition_workflow) }
    let(:process) { create(:workflow_definition_process) }
    let(:process_params) { 
      { 
        process: { 
          selected_processes_attributes: [{workflow_id: workflow.id, position: 200}],
        } 
      } 
    }

    before do
      sign_in(admin)
    end

    context 'when the workflow is published' do
      before do
        workflow.update(published_at: DateTime.now)
        put "/v1/workflow/definition/workflows/#{workflow.id}/add_process/#{process.id}", params: process_params
      end

      it 'returns an error response' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Cannot add processes to a published workflow. Please create a new version to continue.')
      end
    end

    context 'when the workflow is not published' do
      before do
        put "/v1/workflow/definition/workflows/#{workflow.id}/add_process/#{process.id}", params: process_params
      end

      it 'does not creates a new process but associates it with the workflow' do
        expect(response).to have_http_status(:success)
        expect(Workflow::Definition::SelectedProcess.count).to eq(1)

        process = Workflow::Definition::Process.last
        expect(workflow.processes.last).to eq(process)
        expect(process.selected_processes.last.position).to be(200)

        expected_json = V1::Workflow::Definition::ProcessSerializer.new(process, { include: ['steps', 'selected_processes', 'prerequisites'] }).to_json
        # pretty_json = JSON.pretty_generate(JSON.parse(expected_json))
        # puts pretty_json
        expect(response.body).to eq(expected_json)
      end
    end
  end

  describe "POST #new_version" do
    let(:workflow) { create(:workflow_definition_workflow) }
    let(:admin) { create(:user, :admin) }

    before do
      sign_in(admin)
    end

    it "creates a new version of the workflow" do
      post "/v1/workflow/definition/workflows/#{workflow.id}/new_version"

      expect(response).to have_http_status(:success)

      new_version = JSON.parse(response.body)
      expect(new_version["data"]["id"]).to_not eq(workflow.id)
      expect(new_version["data"]["attributes"]["name"]).to eq(workflow.name)
    end
  end

  describe "POST #new_process_version" do
    let(:workflow) { create(:workflow_definition_workflow) }
    let(:process) { create(:workflow_definition_process, version: "v1") }
    let!(:selected_process) { Workflow::Definition::SelectedProcess.create!(workflow_id: workflow.id, process_id: process.id, state: "replicated")}
    let(:admin) { create(:user, :admin) }

    before do
      sign_in(admin)
    end

    it "creates a new version of the process" do
      post "/v1/workflow/definition/workflows/#{workflow.id}/new_version/#{process.id}"

      new_version = JSON.parse(response.body)
      expect(response).to have_http_status(:success)

      expect(selected_process.reload.process_id).to_not eq(process.id)
      expect(selected_process.process_id.to_s).to eq(new_version["data"]["id"])

    end
  end

  describe 'POST #publish' do
    let(:workflow) { create(:workflow_definition_workflow) }
    let(:admin) { create(:user, :admin) }

    before do
      sign_in(admin)
    end
    
    context 'when the workflow is valid' do
      before do
        allow(Workflow::Definition::Workflow::Publish).to receive(:new).and_return(double(validate: true))
        allow(PublishWorkflowJob).to receive(:perform_later)
        put "/v1/workflow/definition/workflows/#{workflow.id}/publish"
      end
      
      it 'returns a success status' do
        expect(response).to have_http_status(:success)
      end
      
      it 'returns a success message' do
        expect(JSON.parse(response.body)['message']).to eq('Rollout in progress')
      end
      
      it 'enqueues the PublishWorkflowJob' do
        expect(PublishWorkflowJob).to have_received(:perform_later).with(workflow.id.to_s)
      end
    end
    
    context 'when the workflow is invalid' do
      before do
        allow(Workflow::Definition::Workflow::Publish).to receive(:new).and_raise(StandardError.new('Validation failed'))
        put "/v1/workflow/definition/workflows/#{workflow.id}/publish"
      end
      
      it 'returns an unprocessable entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
      
      it 'returns an error message' do
        expect(JSON.parse(response.body)['error']).to eq('Validation failed')
      end
    end
  end
end