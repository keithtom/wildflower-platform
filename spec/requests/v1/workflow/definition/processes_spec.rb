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
        # disabling bullet because it thinks we don't need eager loading but we do.
        Bullet.enable = false
        processes = create_list(:workflow_definition_process, 3)
        process_with_steps = processes.first
        process_with_steps.steps = create_list(:workflow_definition_step, 2, process_id: process_with_steps.id)
        get '/v1/workflow/definition/processes'
        processes.first.reload
        expected_json = V1::Workflow::Definition::ProcessSerializer.new(processes).to_json
        expect(response.body).to eq(expected_json)
        Bullet.enable = true
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
        expected_json = V1::Workflow::Definition::ProcessSerializer.new(process, serialization_options).to_json
        # pretty_json = JSON.pretty_generate(JSON.parse(expected_json))
        # puts pretty_json
        
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

      context 'when it has not instances' do
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
    
      context 'when it has instances' do
        before do
          workflow = create(:workflow_instance_workflow)
          process.instances.create!(workflow_id: workflow.id)
        end
      
        it 'returns a bad request response' do
          delete "/v1/workflow/definition/processes/#{process.id}"
          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end

  describe 'POST #create' do
    let(:workflow) { create(:workflow_definition_workflow) }
    let(:prerequisite) { create(:workflow_definition_process) }
    let(:valid_params) { 
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
          selected_processes_attributes: [
            { workflow_id: workflow.id, position: 0}
          ],
          workable_dependencies_attributes: [
            { workflow_id: workflow.id, prerequisite_workable_type: "Workflow::Definition::Process", prerequisite_workable_id: prerequisite.id},
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
        expect(Workflow::Definition::Process.count).to eq(2) # 2 because we also created a prerequisite in the test setup
        expect(Workflow::Definition::SelectedProcess.count).to eq(1)
        expect(Workflow::Definition::Step.count).to eq(2)
        expect(Workflow::DecisionOption.count).to eq(2)
        expect(Document.count).to eq(1)
        expect(Workflow::Definition::Dependency.count).to eq(1)
      end

      it 'returns the created process as JSON' do
        process = Workflow::Definition::Process.last
        expected_json = V1::Workflow::Definition::ProcessSerializer.new(process, serialization_options).to_json
        # pretty_json = JSON.pretty_generate(JSON.parse(expected_json))
        # puts pretty_json
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
        expect(Workflow::Definition::Process.count).to eq(1) # the prerequisite is the only process
      end
    end
  end

  describe 'PUT #update' do
    let!(:process) { create(:workflow_definition_process) }
    let(:workflow) { Workflow::Definition::Workflow.create! }
    let!(:selected_process) { Workflow::Definition::SelectedProcess.create(workflow_id: workflow.id, process_id: process.id, position: 1)}
    let(:valid_params) { { process: { version: '2.0', title: 'Updated Process', description: 'This is an updated process', selected_processes_attributes: [{id: selected_process.id, position: 5}]} } }

    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
      end

      context 'when it is not published' do
        before do
          put "/v1/workflow/definition/processes/#{process.id}", params: valid_params
        end

        it 'updates the process' do
          process.reload
          expect(response).to have_http_status(:success)
          expect(process.version).to eq('2.0')
          expect(process.title).to eq('Updated Process')
          expect(process.description).to eq('This is an updated process')
          expect(process.selected_processes.first.position).to eq(5)
        end

        it 'returns the updated process as JSON' do
          expected_json = V1::Workflow::Definition::ProcessSerializer.new(process.reload, serialization_options).to_json
          expect(response.body).to eq(expected_json)
        end
      end
    
      context 'when it is published' do
        let!(:process) { create(:workflow_definition_process, published_at: DateTime.now) }

        context 'with invalid params' do
          let(:invalid_params) { { process: { version: '2.0', title: 'Updated Process' }}}

          before do
            put "/v1/workflow/definition/processes/#{process.id}", params: invalid_params
          end
        
          it 'does not update the definition or instances' do
            expect(response).to have_http_status(400)
            expect(JSON.parse(response.body)["message"]).to eq("Attribute(s) cannot be an instantaneously changed: version")
            expect(process.reload.version).to_not eq('2.0')
            expect(process.title).to_not eq('Updated Process')
          end
        end

        context 'with valid params' do
          let(:valid_params) { { process: { category_list: ['Finance', 'Admin'], title: 'Updated Process', 
            selected_processes_attributes: [{id: selected_process.id, workflow_id: workflow.id, position: 5}]
          }}}
          let(:workflow_instance) { create(:workflow_instance_workflow, definition_id: workflow.id)}
          let!(:process_instance) { create(:workflow_instance_process, definition_id: process.id, workflow_id: workflow_instance.id)}

          before do
            put "/v1/workflow/definition/processes/#{process.id}", params: valid_params
          end
          
          it 'updates the process' do
            process.reload
            expect(response).to have_http_status(:success)
            expect(process.category_list).to eq(['Finance', 'Admin'])
            expect(process.title).to eq('Updated Process')
            expect(process.selected_processes.first.position).to eq(5)
          end
        
          it 'updates the instances associated to the process' do
            process_instance.reload
            expect(response).to have_http_status(:success)
            expect(process_instance.category_list).to eq(['Finance', 'Admin'])
            expect(process_instance.title).to eq('Updated Process')
            expect(process_instance.position).to eq(5)
          end
        end
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
        expect(process.selected_processes.first.position).to_not eq(5)
      end
    end
  end
end

def serialization_options
  { include: ['steps', 'selected_processes', 'prerequisites'] }
end