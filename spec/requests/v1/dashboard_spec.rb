require 'rails_helper'

RSpec.describe 'V1::Dashboard', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json' } }
  let(:person) { create(:person) }
  let(:user) { create(:user, person_id: person.id) }
  let!(:step) { create(:workflow_instance_step) }
  # let!(:decision_step) { create(:workflow_instance_step, :decision) }
  let(:workflow) { step.process.workflow }
  let(:expected_start_date) { Date.today + 7.days }
  let(:phase) { SSJ::Phase::PHASES.first }

  before do
    sign_in(user)
    team = SSJ::Team.new(expected_start_date:)
    team.workflow = workflow
    team.save!
    SSJ::TeamMember.create!(ssj_team: team, person:, status: SSJ::TeamMember::ACTIVE,
                            role: SSJ::TeamMember::PARTNER)
    p = step.definition.process
    p.category_list << 'Finance'
    p.category_list << 'Human Resources'
    p.category_list << 'unknown category'
    p.save!
    step.assignments.create!(assignee: person)
    p.phase_list << phase
    p.save!
  end

  describe 'GET /v1/dashboard/resources' do
    it 'succeeds' do
      get '/v1/dashboard/resources', headers: headers
      expect(response).to have_http_status(:success)
      expect(json_response['resources']['by_category'][1]['Finance']).not_to be_nil
      expect(json_response['resources']['by_category'][5]['Human Resources']).not_to be_nil
      expect(json_response['resources']['by_category'][5]['Human Resources']).not_to be_empty
      expect(json_response['resources']['by_phase'].first[phase]).not_to be_nil
    end
  end

  describe 'GET /v1/dashboard/progress' do
    context 'when the request is valid' do
      it 'returns the progress data' do
        get '/v1/dashboard/progress', headers: headers
        expect(response).to have_http_status(:success)
      end
    end

    context 'when the request is unauthorized' do
      before do
        sign_out(user)
      end

      it 'returns an unauthorized error message' do
        get '/v1/dashboard/progress', headers: headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /v1/dashboard/progress' do
    context 'when the workflow is recurring' do
      let(:recurring_workflow_definition) do
        create(:workflow_definition_workflow, :with_recurring_processes, recurring: true)
      end
      let!(:recurring_workflow) { recurring_workflow_definition.instances.create! }

      before do
        Workflow::Initialize.run(recurring_workflow.id)
        expect(recurring_workflow.processes.count).to be > 0
      end

      it 'returns the progress data for recurring workflows' do
        get "/v1/dashboard/progress?workflow_id=#{recurring_workflow.external_identifier}", headers: headers
        expect(response).to have_http_status(:success)
        expect(json_response['by_due_month']).to be_an(Array)
        expect(json_response['by_due_month']).not_to be_empty
      end
    end

    context 'when the workflow is non-recurring' do
      let(:non_recurring_workflow_definition) do
        create(:workflow_definition_workflow, :with_processes, recurring: false)
      end
      let!(:non_recurring_workflow) { non_recurring_workflow_definition.instances.create! }

      before do
        Workflow::Initialize.run(non_recurring_workflow.id)
        expect(non_recurring_workflow.processes.count).to be > 0
      end

      it 'returns the progress data for non-recurring workflows' do
        get "/v1/dashboard/progress?workflow_id=#{non_recurring_workflow.external_identifier}", headers: headers
        expect(response).to have_http_status(:success)
        expect(json_response['by_due_month']).to be_an(Array)
        expect(json_response['by_due_month']).to be_empty
      end
    end

    context 'when the request is unauthorized' do
      before do
        sign_out(user)
      end

      it 'returns an unauthorized error message' do
        get '/v1/dashboard/progress', headers: headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
