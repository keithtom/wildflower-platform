require 'rails_helper'

RSpec.describe V1::Workflow::Definition::StepsController, type: :request do
  describe 'POST #create' do
    let(:process) { create(:workflow_definition_process)}
    let(:valid_params) { { 
      step: { process_id: process.id, title: 'Test Step', description: 'This is a test step', kind: Workflow::Definition::Step::DEFAULT, 
      position: 1, completion_type: Workflow::Definition::Step::EACH_PERSON, decision_question: 'are you sure?',               
      decision_options_attributes: [{description: "option 1"}, {description: "option 2"}],
      documents_attributes: [{title: "document title", link: "www.example.com"}]
    } } }

    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
        post '/v1/workflow/definition/steps', params: valid_params
      end

      it 'creates a new step' do
        expect(response).to have_http_status(:success)
        expect(Workflow::Definition::Step.count).to eq(1)
        expect(Workflow::DecisionOption.count).to eq(2)
        expect(Document.count).to eq(1)
      end

      it 'returns the created step as JSON' do
        step = Workflow::Definition::Step.last
        expected_json = V1::Workflow::Definition::StepSerializer.new(step, serializer_options).to_json
        expect(response.body).to eq(expected_json)
      end
    end

    context 'when not authenticated as admin' do
      let(:user) { create(:user) }

      before do
        sign_in(user)
        post '/v1/workflow/definition/steps', params: valid_params
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not create a new step' do
        expect(Workflow::Definition::Step.count).to eq(0)
      end
    end
  end

  describe 'PUT #update' do
    let!(:step) { create(:workflow_definition_step) }
    let(:process) { create(:workflow_definition_process)}
    let(:valid_params) { { step: { 
      process_id: process.id, title: 'Updated Step', description: 'This is an updated step', 
      kind: Workflow::Definition::Step::DECISION, position: 2, completion_type: Workflow::Definition::Step::ONE_PER_GROUP, decision_question: 'Are you sure?' 
    } } }

    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
        put "/v1/workflow/definition/steps/#{step.id}", params: valid_params
      end

      it 'updates the step' do
        step.reload
        expect(response).to have_http_status(:success)
        expect(step.process_id).to eq(process.id)
        expect(step.title).to eq('Updated Step')
        expect(step.description).to eq('This is an updated step')
        expect(step.kind).to eq(Workflow::Definition::Step::DECISION)
        expect(step.position).to eq(2)
        expect(step.completion_type).to eq(Workflow::Definition::Step::ONE_PER_GROUP)
        expect(step.decision_question).to eq('Are you sure?')
      end

      it 'returns the updated step as JSON' do
        expected_json = V1::Workflow::Definition::StepSerializer.new(step.reload, serializer_options).to_json
        expect(response.body).to eq(expected_json)
      end
    end

    context 'when not authenticated as admin' do
      let(:user) { create(:user) }

      before do
        sign_in(user)
        put "/v1/workflow/definition/steps/#{step.id}", params: valid_params
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not update the step' do
        step.reload
        expect(step.process_id).not_to eq(process.id)
        expect(step.title).not_to eq('Updated Step')
        expect(step.description).not_to eq('This is an updated step')
        expect(step.kind).not_to eq('decision')
        expect(step.position).not_to eq(2)
        expect(step.completion_type).not_to eq('manual')
        expect(step.decision_question).not_to eq('Are you sure?')
      end
    end
  end

  describe 'GET #index' do
    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
      end

      it 'returns a success response' do
        get '/v1/workflow/definition/steps'
        expect(response).to have_http_status(:success)
      end

      it 'returns all steps as JSON' do
        steps = create_list(:workflow_definition_step, 3)
        get '/v1/workflow/definition/steps'
        expected_json = V1::Workflow::Definition::StepSerializer.new(steps, serializer_options).to_json
        expect(response.body).to eq(expected_json)
      end
    end

    context 'when not authenticated as admin' do
      let(:user) { create(:user) }

      before do
        sign_in(user)
      end

      it 'returns unauthorized status' do
        get '/v1/workflow/definition/steps'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET #show' do
    let(:step) { create(:workflow_definition_step) }

    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
      end

      it 'returns a success response' do
        get "/v1/workflow/definition/steps/#{step.id}"
        expect(response).to have_http_status(:success)
      end

      it 'returns the step as JSON' do
        get "/v1/workflow/definition/steps/#{step.id}"
        expected_json = V1::Workflow::Definition::StepSerializer.new(step, serializer_options).to_json
        expect(response.body).to eq(expected_json)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:step) { create(:workflow_definition_step) }
    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
      end

      it 'returns a success response' do
        delete "/v1/workflow/definition/steps/#{step.id}"
        expect(response).to have_http_status(:success)
      end

      it 'deletes the step' do
        expect {
          delete "/v1/workflow/definition/steps/#{step.id}"
        }.to change(Workflow::Definition::Step, :count).by(-1)
      end

      it 'returns a success message' do
        delete "/v1/workflow/definition/steps/#{step.id}"
        expect(response.body).to eq({ message: 'Step deleted successfully' }.to_json)
      end
    end
  end
end

def serializer_options
  { include: ['documents', 'decision_options']}
end