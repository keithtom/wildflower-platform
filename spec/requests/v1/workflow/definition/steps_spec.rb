# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Workflow::Definition::StepsController, type: :request do
  describe 'POST #create' do
    let(:process) { create(:workflow_definition_process)}
    let(:valid_params) { { 
      step: { title: 'Test Step', description: 'This is a test step', kind: Workflow::Definition::Step::DEFAULT, 
      position: 1, completion_type: Workflow::Definition::Step::EACH_PERSON, decision_question: 'are you sure?',               
      decision_options_attributes: [{description: "option 1"}, {description: "option 2"}],
      documents_attributes: [{title: "document title", link: "www.example.com"}]
    } } }

    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
        post "/v1/workflow/definition/processes/#{process.id}/steps", params: valid_params
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
        post "/v1/workflow/definition/processes/#{process.id}/steps", params: valid_params
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
    let(:process) { create(:workflow_definition_process)}
    let(:process2) { create(:workflow_definition_process)}
    let!(:step) { create(:workflow_definition_step, process_id: process.id) }
    let!(:instance_step) { create(:workflow_instance_step, definition: step, title: "A Step", description: "original, unupdated step") }
    let(:valid_params) { { step: { 
      process_id: process2.id,
      title: 'Updated Step', description: 'This is an updated step', 
      kind: Workflow::Definition::Step::DECISION, position: 2, completion_type: Workflow::Definition::Step::ONE_PER_GROUP, decision_question: 'Are you sure?' 
    } } }

    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
      end

      context 'when parent process is not published' do
        before do
          put "/v1/workflow/definition/processes/#{process.id}/steps/#{step.id}", params: valid_params
        end

        it 'updates the step' do
          step.reload
          puts response.inspect
          expect(response).to have_http_status(:success)
          expect(step.process_id).to eq(process2.id)
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

        context "updating position to an invalid one" do
          let(:valid_params) { { step: { position: 0 } } } 

          it "returns a 422 status" do
            expect(response).to have_http_status(422)
          end
        end
      end

      context 'parent process is published' do
        let(:valid_params) { { step: { 
          title: 'Updated Step', description: 'This is an updated step', position: 2, 
          completion_type: Workflow::Definition::Step::ONE_PER_GROUP, decision_question: 'Are you sure?',
          documents_attributes: [{title: "basic resource", link: "www.example.com"}]
        } } }
        let(:process) { create(:workflow_definition_process, published_at: DateTime.now)}

        context 'with valid params' do
          before do
            put "/v1/workflow/definition/processes/#{process.id}/steps/#{step.id}", params: valid_params
          end

          it 'updates the step instances instantaneously' do
            step.reload
            expect(response).to have_http_status(:success)
            expect(step.title).to eq('Updated Step')
            expect(step.description).to eq('This is an updated step')
            expect(step.position).to eq(2)
            expect(step.completion_type).to eq(Workflow::Definition::Step::ONE_PER_GROUP)
            expect(step.decision_question).to eq('Are you sure?')
            expect(step.documents.last.title).to eq('basic resource')
          
            expect(instance_step.reload.title).to eq('Updated Step')
            expect(instance_step.description).to eq('This is an updated step')
          end
        end

        context 'with invalid params' do
          let(:invalid_params) { {step: {title: 'Updated Step', kind: 'Decision'}}}

          before do
            put "/v1/workflow/definition/processes/#{process.id}/steps/#{step.id}", params: invalid_params
          end

          it 'does not update the definition or instances' do
            expect(response).to have_http_status(:unprocessable_entity)
            expect(JSON.parse(response.body)['message']).to eq('Attribute(s) cannot be an instantaneously changed: kind')
            expect(step.reload.title).not_to eq('Updated Step')
            expect(instance_step.reload.title).not_to eq('Updated Step')
          end
        end
      end
    end

    context 'when not authenticated as admin' do
      let(:user) { create(:user) }

      before do
        sign_in(user)
        put "/v1/workflow/definition/processes/#{process.id}/steps/#{step.id}", params: valid_params
      end

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not update the step' do
        step.reload
        expect(step.process_id).not_to eq(nil)
        expect(step.title).not_to eq('Updated Step')
        expect(step.description).not_to eq('This is an updated step')
        expect(step.kind).not_to eq('decision')
        expect(step.position).not_to eq(2)
        expect(step.completion_type).not_to eq('manual')
        expect(step.decision_question).not_to eq('Are you sure?')
      end
    end
  end

  describe 'GET #show' do
    let(:process) { create(:workflow_definition_process) }
    let!(:step) { create(:workflow_definition_step, process_id: process.id) }

    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
      end

      it 'returns a success response' do
        get "/v1/workflow/definition/processes/#{process.id}/steps/#{step.id}"
        expect(response).to have_http_status(:success)
      end

      it 'returns the step as JSON' do
        get "/v1/workflow/definition/processes/#{process.id}/steps/#{step.id}"
        expected_json = V1::Workflow::Definition::StepSerializer.new(step, serializer_options).to_json
        expect(response.body).to eq(expected_json)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:process) { create(:workflow_definition_process) }
    let!(:step) { create(:workflow_definition_step, process_id: process.id) }

    context 'when authenticated as admin' do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
      end

      it 'returns a success response' do
        delete "/v1/workflow/definition/processes/#{process.id}/steps/#{step.id}"
        expect(response).to have_http_status(:success)
      end

      it 'deletes the step' do
        expect {
          delete "/v1/workflow/definition/processes/#{process.id}/steps/#{step.id}"
        }.to change(Workflow::Definition::Step, :count).by(-1)
      end

      it 'returns a success message' do
        delete "/v1/workflow/definition/processes/#{process.id}/steps/#{step.id}"
        expect(response.body).to eq({ message: 'Step deleted successfully' }.to_json)
      end
    end
  end
end

def serializer_options
  { include: ['documents', 'decision_options']}
end