require 'rails_helper'

RSpec.describe 'V1::Workflow::Steps', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json' } }
  let(:user) { create(:user, person:) }
  let(:person) { create(:person) }
  let(:workflow) { create(:workflow_instance_workflow) }
  let(:process) { create(:workflow_instance_process, workflow:) }
  let!(:step) { create(:workflow_instance_step, process:) }

  describe 'GET /v1/workflow/processes/6982-2091/steps/bd8f-c3b2' do
    before do
      sign_in(user)
    end

    it 'succeeds' do
      get "/v1/workflow/processes/#{process.external_identifier}/steps/#{step.external_identifier}", headers: headers
      expect(response).to have_http_status(:success)
      expect(json_response['data']).to have_type(:step).and have_attribute(:title)
    end
  end

  context 'when part of an ssj team' do
    let(:ssj_team) { create(:ssj_team, workflow:) }

    before do
      sign_in(user)
      SSJ::TeamMember.create(person:, ssj_team:, role: SSJ::TeamMember::PARTNER,
                             status: SSJ::TeamMember::ACTIVE)
    end

    describe 'PUT /v1/workflow/steps/bd8f-c3b2/assign' do
      it 'succeeds' do
        put "/v1/workflow/steps/#{step.external_identifier}/assign", headers: headers
        expect(response).to have_http_status(:success)
        expect(step.assignments.first.assignee).to eq(person)
      end
    end

    describe 'PUT /v1/workflow/steps/bd8f-c3b2/unassign' do
      before { step.assignments.create!(assignee: person) }

      it 'succeeds' do
        expect(step.assignments.count).to eq(1)
        put "/v1/workflow/steps/#{step.external_identifier}/unassign", headers: headers,
                                                                       params: { assignee_id: person.external_identifier }

        expect(response).to have_http_status(:success)
        step.reload
        expect(step.assignments.count).to eq(0)
      end
    end

    describe 'PUT /v1/workflow/steps/bd8f-c3b2/complete' do
      let(:first_phase) { SSJ::Phase::PHASES[0] }
      let(:second_phase) { SSJ::Phase::PHASES[1] }

      it 'succeeds' do
        put "/v1/workflow/steps/#{step.external_identifier}/complete", headers: headers
        expect(response).to have_http_status(:success)
        expect(step.reload.completed).to be true
      end

      # move this to a service spec.
      context 'completing the last step of the last process in a phase' do
        before do
          process.definition.phase_list = first_phase
          process.definition.save!
        end

        it 'completes the process and updates the current phase of the workflow' do
          expect(process.workflow.current_phase).to eq(first_phase)
          put "/v1/workflow/steps/#{step.external_identifier}/complete", headers: headers
          expect(process.reload.completed_at).not_to be_nil
          expect(process.workflow.current_phase).to eq(second_phase)
        end
      end

      context 'completing any step but the last step of a process' do
        let!(:another_step) { create(:workflow_instance_step, process:) }

        before do
          process.definition.phase_list = first_phase
          process.definition.save!
        end

        it 'does not complete the process or update the current phase of the workflow' do
          expect(process.workflow.current_phase).to eq(first_phase)
          put "/v1/workflow/steps/#{step.external_identifier}/complete", headers: headers
          expect(process.reload.completed_at).to be_nil
          expect(process.workflow.current_phase).to eq(first_phase)
        end
      end
    end

    describe 'PUT /v1/workflow/steps/bd8f-c3b2/uncomplete' do
      it 'succeeds' do
        put "/v1/workflow/steps/#{step.external_identifier}/uncomplete", headers: headers
        expect(response).to have_http_status(:success)
        expect(step.reload.completed).to be false
        expect(step.assignments.count).to eq(0)
      end
    end

    describe 'POST /v1/workflow/processes/6982-2091/steps' do
      it 'succeeds' do
        title = 'copy visioning template'
        post "/v1/workflow/processes/#{process.external_identifier}/steps", headers: headers,
                                                                            params: { step: { title:, kind: Workflow::Definition::Step::DEFAULT, completion_type: Workflow::Definition::Step::ONE_PER_GROUP } }
        expect(response).to have_http_status(:success)
        expect(json_response['data']).to have_type(:step).and have_attribute(:title)
        new_step = Workflow::Instance::Step.last
        expect(new_step.title).to eq(title)
        expect(new_step.position).to eq(2000)
      end
    end

    describe 'PUT /v1/workflow/steps/reorder' do
      context 'when step is from definition,' do
        it 'fails' do
          put "/v1/workflow/steps/#{step.external_identifier}/reorder", headers: headers,
                                                                        params: { step: { position: 200 } }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response['error']).not_to be_empty
        end
      end

      context 'when step is manually created, reordered' do
        let(:step) { create(:workflow_instance_step_manual, process:, position: 4000) }

        before do
          3.times do |i|
            create(:workflow_instance_step, process:, position: 1000 * (i + 1))
          end
        end

        context 'to the front of the list' do
          let(:after_position) { 0 }

          it 'succeeds' do
            put "/v1/workflow/steps/#{step.external_identifier}/reorder", headers: headers,
                                                                          params: { step: { after_position: } }
            expect(response).to have_http_status(:success)
            expect(step.reload.position).to be(500)
          end
        end

        context 'to the end of the list' do
          let(:step) { create(:workflow_instance_step_manual, process:, position: 1500) }
          let(:after_position) { 3000 }

          it 'succeeds' do
            put "/v1/workflow/steps/#{step.external_identifier}/reorder", headers: headers,
                                                                          params: { step: { after_position: } }
            expect(response).to have_http_status(:success)
            expect(step.reload.position).to be(4000)
          end
        end

        context 'between two steps' do
          let(:after_position) { 2000 }

          it 'succeeds' do
            put "/v1/workflow/steps/#{step.external_identifier}/reorder", headers: headers,
                                                                          params: { step: { after_position: } }
            expect(response).to have_http_status(:success)
            expect(step.reload.position).to be(2500)
          end
        end
      end
    end

    describe 'PUT /v1/workflow/steps/:id/select_option' do
      let(:select_option) { step.definition.decision_options.first }

      before do
        definition = step.definition
        3.times do |i|
          step.definition.decision_options.create(description: "option #{i}")
        end
      end

      it 'selects an option for a step of kind: decision' do
        put "/v1/workflow/steps/#{step.external_identifier}/select_option", headers: headers,
                                                                            params: { step: { selected_option_id: select_option.external_identifier } }
        expect(response).to have_http_status(:success)
        expect(step.assignments.for_person_id(person.id).first.selected_option).to eq(select_option)
      end
    end
  end

  context 'when part of a school' do
    let!(:school_relationship) { create(:school_relationship, person:, school:) }
    let(:school) { create(:school, workflow_id: workflow.id) }

    before do
      sign_in(user)
    end

    context 'assigning step to current user' do
      describe 'PUT /v1/workflow/steps/bd8f-c3b2/assign' do
        it 'succeeds' do
          put "/v1/workflow/steps/#{step.external_identifier}/assign", headers: headers
          expect(response).to have_http_status(:success)
          expect(step.assignments.first.assignee).to eq(person)
        end
      end
    end

    context 'assigning step to a different user' do
      let(:new_person) { create(:person) }
      let!(:school_relationship) { create(:school_relationship, person: new_person, school:) }
      let(:valid_params) { { person_id: new_person.external_identifier } }

      describe 'PUT /v1/workflow/steps/bd8f-c3b2/assign' do
        it 'succeeds' do
          put "/v1/workflow/steps/#{step.external_identifier}/assign", headers: headers, params: valid_params
          expect(response).to have_http_status(:success)
          expect(step.assignments.first.assignee).to eq(new_person)
        end
      end
    end

    describe 'PUT /v1/workflow/steps/bd8f-c3b2/unassign' do
      before { step.assignments.create!(assignee: person) }

      context 'unassigner is part of school' do
        it 'succeeds' do
          expect(step.assignments.count).to eq(1)
          put "/v1/workflow/steps/#{step.external_identifier}/unassign", headers: headers,
                                                                         params: { assignee_id: person.external_identifier }

          expect(response).to have_http_status(:success)
          step.reload
          expect(step.assignments.count).to eq(0)
        end
      end

      context 'unassigner is NOT part of school' do
        let(:person2) { create(:person) }
        let!(:school_relationship) { create(:school_relationship, person: person2, school:) }
        let!(:school) { create(:school, workflow_id: workflow.id) }

        it 'succeeds' do
          Bullet.enable = false
          puts school.workflow_id
          expect(step.assignments.count).to eq(1)
          put "/v1/workflow/steps/#{step.external_identifier}/unassign", headers: headers,
                                                                         params: { assignee_id: person2.external_identifier }

          expect(response).to have_http_status(:bad_request)
          step.reload
          expect(step.assignments.count).to eq(1)
          Bullet.enable = true
        end
      end
    end
  end
end
