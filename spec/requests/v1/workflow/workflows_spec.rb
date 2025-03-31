require 'rails_helper'

RSpec.describe 'V1::Workflow::Workflows', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json' } }
  let(:workflow) { create(:workflow_instance_workflow) }
  let(:user) { create(:user, :with_person) }
  let(:user_admin) { create(:user, :admin) }
  let(:workflow_definition) { create(:workflow_definition_workflow) }
  let(:school) { create(:school) }

  before do
    sign_in(user)
  end

  describe 'GET /v1/workflow/workflows/:id' do
    it 'succeeds' do
      get "/v1/workflow/workflows/#{workflow.external_identifier}", headers: headers
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /v1/workflow/workflows/:id/resources' do
    before do
      album_process = create(:workflow_instance_process, workflow:)
      album_process.category_list.add('Album Advice & Affiliation')
      album_process.save!

      3.times do
        step_definition = create(:workflow_definition_step, process: album_process.definition)
        step = create(:workflow_instance_step, process: album_process, definition: step_definition)
      end

      finance_process = create(:workflow_instance_process, workflow:)
      finance_process.category_list.add('Finance')
      finance_process.save!

      3.times do
        step_definition = create(:workflow_definition_step, process: finance_process.definition)
        step = create(:workflow_instance_step, process: finance_process, definition: step_definition)
      end
    end

    it 'succeeds' do
      get "/v1/workflow/workflows/#{workflow.external_identifier}/resources", headers: headers
      expect(response).to have_http_status(:success)
      expect(json_response['data'].count).to be(6)
      expect(json_response['data'].first).to have_attribute('categories')
    end

    context 'when phase parameter is present' do
      it 'uses ResourcesByCategoryAndPhaseSerializer' do
        get "/v1/workflow/workflows/#{workflow.external_identifier}/resources?phase=true", headers: headers
        expect(response).to have_http_status(:success)
        expect(response.body).to include('by_phase')
      end
    end

    context 'when phase parameter is not present' do
      it 'uses ResourceSerializer' do
        get "/v1/workflow/workflows/#{workflow.external_identifier}/resources", headers: headers
        expect(response).to have_http_status(:success)
        expect(response.body).to include('"type":"resource"')
      end
    end
  end

  describe 'GET /v1/workflow/workflows/:workflow_id/assigned_steps' do
    let!(:step) { create(:workflow_instance_step) }
    let(:workflow) { step.process.workflow }

    before do
      step.assignments.create!(assignee: user.person)
    end

    it 'succeeds' do
      # disabling bullet because it thinks we don't need to eager load decision options. In practice, there will be assigned steps with decision options
      Bullet.enable = false
      get "/v1/workflow/workflows/#{workflow.external_identifier}/assigned_steps", headers: headers
      expect(response).to have_http_status(:success)
      expect(json_response['data'][0]).to have_type('step')
      expect(json_response['data'][0]).to have_attribute('kind')
      expect(json_response['data'][0]).to have_relationships('process', 'documents', 'assignments')
      expect(json_response['included']).to include(have_type('person'))
      expect(json_response['included']).to include(have_type('assignment'))
      expect(json_response['included']).to include(have_type('document'))
      expect(json_response['included']).to include(have_type('process'))
      Bullet.enable = true
    end
  end

  describe 'POST /v1/workflow/workflows' do
    let(:user) { create(:user, :admin) }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          workflow: {
            definition_id: workflow_definition.id,
            school_id: school.external_identifier
          }
        }
      end

      it 'creates a new workflow and returns it' do
        expect(Workflow::InitializeWorkflowJob).to receive(:perform_later).once

        post '/v1/workflow/workflows', params: valid_params, headers: headers

        expect(response).to have_http_status(:success)
        expect(json_response['data']).to have_type('workflow')
        expect(json_response['data']['attributes']).to include('visible' => true)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          workflow: {
            definition_id: 5,
            school_id: nil
          }
        }
      end

      it 'returns an error message' do
        post '/v1/workflow/workflows', params: invalid_params, headers: headers

        expect(response).to have_http_status(:not_found)
        expect(json_response).to have_key('error')
      end
    end
  end
end
