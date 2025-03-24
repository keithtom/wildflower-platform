require 'rails_helper'

RSpec.describe 'V1::SchoolRelationships', type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json' } }
  let(:user) { create(:user) }
  let!(:school) { create(:school) }
  let(:person) { create(:person) }
  let(:ops_guide) { create(:person) }
  let!(:school_relationship) { create(:school_relationship, school:, person: ops_guide) }

  before do
    sign_in(user)
  end

  describe 'POST /v1/school_relationships' do
    let(:valid_params) do
      {
        school_relationship: {
          description: 'Test Description',
          start_date: Date.today,
          end_date: nil,
          title: 'Teacher',
          school_id: school.external_identifier,
          person_id: person.external_identifier,
          role_list: ['Teacher Leader']
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new school relationship' do
        expect do
          post '/v1/school_relationships', params: valid_params, headers:
        end.to change(SchoolRelationship, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['data']).to have_type('schoolRelationship')
        expect(json_response['data']['attributes']).to include(
          'description' => 'Test Description',
          'startDate' => Date.today.to_s
        )
        expect(json_response['included']).to include(
          have_type('school'),
          have_type('person')
        )
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          school_relationship: {
            title: 'Test Relationship'
            # Missing required parameters
          }
        }
      end

      it 'returns an error response' do
        post '/v1/school_relationships', params: invalid_params, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to have_key('error')
      end
    end

    context 'when SchoolRelationship::Create service raises an error' do
      before do
        allow(SchoolRelationship::Create).to receive(:run).and_raise(StandardError, 'Custom error message')
      end

      it 'returns an error response' do
        post '/v1/school_relationships', params: valid_params, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Custom error message')
      end
    end
  end
end
