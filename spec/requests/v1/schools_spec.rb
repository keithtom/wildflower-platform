require 'rails_helper'

describe 'API V1 School', type: :request do
  let(:school) { create(:school) }
  let(:person) { create(:person) }
  let(:address) { create(:address) }
  let(:headers) { { 'ACCEPT' => 'application/json' } }

  before do
    create(:school)
    sign_in(user)
  end

  describe 'non admin user endpoints' do
    let(:user) { create(:user) }

    before do
      sr = create(:school_relationship, person:, school:)
      sr.role_list.add(Person::TL)
    end

    describe 'GET /v1/schools' do
      it 'succeeds' do
        Bullet.enable = false
        get '/v1/schools', headers: { 'ACCEPT' => 'application/json' }
        expect(response).to have_http_status(:success)
        Bullet.enable = true
      end

      describe 'with person_id query parameter' do
        it 'succeeds' do
          Bullet.enable = false
          get "/v1/schools?person_id=#{person.external_identifier}", headers: { 'ACCEPT' => 'application/json' }
          expect(response).to have_http_status(:success)
          expect(json_response['data'].first['id']).to eq(school.external_identifier)
          Bullet.enable = true
        end
      end

      describe 'with role and person_id query parameter' do
        it 'succeeds' do
          get "/v1/schools?person_id=#{person.external_identifier}&role=Ops%20Guide",
              headers: { 'ACCEPT' => 'application/json' }
          expect(response).to have_http_status(:success)
          expect(json_response['data']).to be_empty
        end
      end

      describe 'with name only query parameter' do
        it 'succeeds' do
          get '/v1/schools?name_only=true',
              headers: { 'ACCEPT' => 'application/json' }
          expect(response).to have_http_status(:success)
        end
      end

      context 'with pagination' do
        before do
          Bullet.enable = false
          # Create 30 schools to test pagination
          create_list(:school, 30)
        end

        after do
          Bullet.enable = true
        end

        it 'returns paginated results with default values' do
          get '/v1/schools', headers: headers

          expect(response).to have_http_status(:success)
          expect(json_response['data'].length).to eq(25) # default per_page
          expect(json_response['meta']).to include(
            'current_page' => 1,
            'per_page' => 25,
            'total_entries' => 32, # 30 created + 2 from before block
            'total_pages' => 2
          )
        end

        it 'respects custom page and per_page parameters' do
          get '/v1/schools', params: { page: 2, per_page: 10 }, headers: headers

          expect(response).to have_http_status(:success)
          expect(json_response['data'].length).to eq(10)
          expect(json_response['meta']).to include(
            'current_page' => 2,
            'per_page' => 10,
            'total_entries' => 32,
            'total_pages' => 4
          )
        end

        it 'returns the last page with remaining records' do
          get '/v1/schools', params: { page: 4, per_page: 10 }, headers: headers

          expect(response).to have_http_status(:success)
          expect(json_response['data'].length).to eq(2) # Last page with remaining record
          expect(json_response['meta']).to include(
            'current_page' => 4,
            'per_page' => 10,
            'total_entries' => 32,
            'total_pages' => 4
          )
        end

        context 'with invalid pagination parameters' do
          it 'handles negative page numbers gracefully' do
            get '/v1/schools', params: { page: -1 }, headers: headers

            expect(response).to have_http_status(:success)
            expect(json_response['meta']).to include(
              'current_page' => 1  # Should default to first page
            )
          end

          it 'handles zero page number gracefully' do
            get '/v1/schools', params: { page: 0 }, headers: headers

            expect(response).to have_http_status(:success)
            expect(json_response['meta']).to include(
              'current_page' => 1  # Should default to first page
            )
          end

          it 'handles negative per_page gracefully' do
            get '/v1/schools', params: { per_page: -5 }, headers: headers

            expect(response).to have_http_status(:success)
            expect(json_response['meta']).to include(
              'per_page' => 25  # Should use default per_page
            )
          end

          it 'handles too large per_page gracefully' do
            get '/v1/schools', params: { per_page: 1000 }, headers: headers

            expect(response).to have_http_status(:success)
            expect(json_response['meta']).to include(
              'per_page' => 50  # Should use max per_page
            )
          end

          it 'handles non-numeric pagination parameters gracefully' do
            get '/v1/schools', params: { page: 'abc', per_page: 'def' }, headers: headers

            expect(response).to have_http_status(:success)
            expect(json_response['meta']).to include(
              'current_page' => 1,
              'per_page' => 25  # Should use defaults
            )
          end
        end

        context 'with empty result sets' do
          before do
            School.destroy_all
          end

          it 'returns empty data array with correct metadata' do
            get '/v1/schools', headers: headers

            expect(response).to have_http_status(:success)
            expect(json_response['data']).to be_empty
            expect(json_response['meta']).to include(
              'current_page' => 1,
              'per_page' => 25,
              'total_entries' => 0,
              'total_pages' => 1
            )
          end
        end

        context 'when requesting a page beyond total pages' do
          it 'returns empty data array with correct metadata' do
            get '/v1/schools', params: { page: 100 }, headers: headers

            expect(response).to have_http_status(:success)
            expect(json_response['data']).to be_empty
            expect(json_response['meta']).to include(
              'current_page' => 100,
              'total_pages' => 2 # With 31 records and 25 per page, should have 2 pages
            )
          end
        end
      end
    end

    describe 'GET /v1/schools/1' do
      it 'succeeds' do
        Bullet.enable = false ## failing on Github Actions CI, but not locally, no idea why.
        get "/v1/schools/#{school.external_identifier}", headers: { 'ACCEPT' => 'application/json' }
        expect(response).to have_http_status(:success)
        expect(json_response['included']).to include(have_type(:person).and(have_attribute(:email)))
        Bullet.enable = true
      end

      context 'with serialization_fields parameter' do
        it 'returns only requested fields and relationships' do
          get "/v1/schools/#{school.external_identifier}?serialization_fields=name,status,school_relationships",
              headers: { 'ACCEPT' => 'application/json' }

          expect(response).to have_http_status(:success)

          # Check that only requested attributes are present
          attributes = json_response['data']['attributes']
          expect(attributes.keys).to match_array(%w[name status])
          expect(attributes.keys).not_to include('about', 'maxEnrollment', 'numClassrooms')

          # Check that school_relationships are included
          expect(json_response['data']['relationships']).to have_key('schoolRelationships')
          expect(json_response['included']).to include(have_type(:schoolRelationship))

          # Check that other relationships are not included
          relationships = json_response['data']['relationships']
          expect(relationships.keys).not_to include('address', 'sister_schools')
        end
      end

      context 'with an included person that has several school_relationships' do
        let!(:other_school) { create(:school) }
        let!(:another_school) { create(:school) }

        before do
          # Create additional relationships for the person
          create(:school_relationship, person:, school: other_school)
          create(:school_relationship, person:, school: another_school)
        end

        it 'does not include schools or school_relationships in the included person object' do
          Bullet.enable = false
          get "/v1/schools/#{school.external_identifier}", headers: { 'ACCEPT' => 'application/json' }
          Bullet.enable = true
          expect(response).to have_http_status(:success)

          # Find the person in the included array
          included_person = json_response['included'].find do |inc|
            inc['type'] == 'person' && inc['id'] == person.external_identifier
          end

          # Verify the person does not have schools or school_relationships included
          expect(included_person['relationships']).not_to include('schools')
          expect(included_person['relationships']).not_to include('schoolRelationships')
        end
      end
    end

    describe 'PUT /v1/schools/1' do
      let(:person1) { create(:person) }
      let(:person2) { create(:person) }
      let(:person3) { create(:person) }

      it 'succeeds' do
        current_school_id = school.address.id
        put "/v1/schools/#{school.external_identifier}",
            params: { school: {
              about: 'new about',
              school_relationships_attributes: [
                { person_id: person1.id },
                { person_id: person2.id },
                { person_id: person3.id }
              ],
              address_attributes: {
                city: 'new city',
                state: 'new state'
              },
              opened_on: '2018-01-01',
              ages_served_list: %w[elementary middle],
              governance_type: 'charter',
              max_enrollment: 100
            } },
            headers: { 'ACCEPT' => 'application/json' }
        expect(response).to have_http_status(:success)

        school.reload
        expect(school.address.id).to eq(current_school_id)
        expect(school.address.city).to eq('new city')
        expect(school.people).to include(person1, person2, person3)
        expect(school.ages_served_list).to match_array(%w[elementary middle])
      end
    end
  end

  describe 'POST /v1/schools' do
    let(:user) { create(:user, :admin) }
    let(:ops_guide_user) { create(:user, :with_person) }
    let(:rgl_user) { create(:user, :with_person) }
    let(:ops_guide) { ops_guide_user.person }
    let(:rgl) { rgl_user.person }
    let(:workflow_definition) { create(:workflow_definition_workflow, published_at: DateTime.now) }
    let(:etl_people_params) do
      [
        { first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email },
        { first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email }
      ]
    end
    let(:etl_params_controller) do
      ActionController::Parameters.new({ school: { etl_people_params: } }).require(:school).permit([etl_people_params: %i[
                                                                                                     first_name last_name email
                                                                                                   ]])
    end

    context 'when an admin makes the request' do
      before do
        allow(controller).to receive(:authenticate_admin!).and_return(true)
        allow(Person).to receive(:find_by!).with(external_identifier: ops_guide.external_identifier).and_return(ops_guide)
        allow(Person).to receive(:find_by!).with(external_identifier: rgl.external_identifier).and_return(rgl)
        allow(SSJ::InviteSchool).to receive(:run).with(etl_params_controller[:etl_people_params],
                                                       workflow_definition.id.to_s, ops_guide, rgl).and_return(school)
      end

      context 'when the school is successfully invited' do
        it 'returns a success message' do
          post '/v1/schools',
               params: { school: { workflow_id: workflow_definition.id, ops_guide_id: ops_guide.external_identifier,
                                   rgl_id: rgl.external_identifier, etl_people_params: } },
               headers: headers
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq({ 'message' => "school #{school.external_identifier} invite emails sent" })
        end
      end

      context 'when inviting the school fails' do
        let(:error_message) { 'Something went wrong' }
        let(:school) { nil }

        before do
          allow(SSJ::InviteSchool).to receive(:run).and_raise(error_message)
        end

        it 'returns an error message' do
          post '/v1/schools',
               params: { school: { workflow_id: workflow_definition.id, ops_guide_id: ops_guide.external_identifier,
                                   rgl_id: rgl.external_identifier, etl_people_params: } },
               headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to eq({ 'message' => error_message })
        end
      end
    end

    context 'when a non-admin makes the request' do
      before do
        allow(user).to receive(:is_admin).and_return(false)
      end

      it 'returns an unauthorized error message' do
        post '/v1/schools',
             params: { school: { workflow_id: workflow_definition.id, ops_guide_id: ops_guide.external_identifier, rgl_id: rgl.external_identifier,
                                 etl_people_params: } },
             headers: headers
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ 'message' => 'Unauthorized' })
      end
    end
  end

  describe 'PUT /v1/schools/:school_id/invite_partner' do
    let(:user) { create(:user, :admin) }
    let(:school) { create(:school, status:) }
    let(:person_params) { { email: 'partner@example.com', first_name: 'John', last_name: 'Doe' } }
    let(:school_relationship_params) { { title: 'Partner', start_date: '2023-01-01' } }

    context 'when the request is valid (TL)' do
      let(:status) { School::Status::OPEN }

      it 'invites a partner and returns the updated school' do
        expect(OpenTlMailer).to receive(:invite_partner).and_call_original

        put "/v1/schools/#{school.external_identifier}/invite_partner",
             params: { person: person_params, school_relationship: school_relationship_params },
             headers: headers
        expect(response).to have_http_status(:success)
        expect(json_response['data']['id']).to eq(school.external_identifier)
        expect(json_response['included']).to include(have_type(:person).and(have_attribute(:email).with_value('partner@example.com')))
        expect(json_response['included']).to include(have_type(:person).and(have_attribute(:roleList).with_value(['Teacher Leader'])))
        expect(json_response['included']).to include(have_type(:person).and(have_attribute(:active).with_value(true)))
      end
    end

    context 'when the request is valid' do
      let(:status) { School::Status::EMERGING }

      it 'invites a partner and returns the updated school' do
        expect(SSJMailer).to receive(:invite_partner).and_call_original

        put "/v1/schools/#{school.external_identifier}/invite_partner",
             params: { person: person_params },
             headers: headers
        expect(response).to have_http_status(:success)
        expect(json_response['data']['id']).to eq(school.external_identifier)
        expect(json_response['included']).to include(have_type(:person).and(have_attribute(:email).with_value('partner@example.com')))
        expect(json_response['included']).to include(have_type(:person).and(have_attribute(:roleList).with_value(['Emerging Teacher Leader'])))
        expect(json_response['included']).to include(have_type(:person).and(have_attribute(:active).with_value(false)))
      end
    end

    context 'when the request is invalid' do
      before do
        allow(School::InvitePartner).to receive(:run).and_raise(StandardError, 'Something went wrong')
      end

      it 'returns an error message' do
        Bullet.enable = false
        put "/v1/schools/#{school.external_identifier}/invite_partner",
             params: { person: person_params, school_relationship: school_relationship_params },
             headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Something went wrong')
        Bullet.enable = true
      end
    end
  end

  describe 'PUT /v1/schools/:school_id/reinvite_partner' do
    let(:user) { create(:user, :admin) }
    let(:school) { create(:school, status:) }
    let(:person) { create(:person) }
    let(:person_params) { { id: person.external_identifier } }

    context 'when the request is valid (TL)' do
      let(:status) { School::Status::OPEN }

      it 'invites a partner and returns the updated school' do
        expect(OpenTlMailer).to receive(:invite_partner).and_call_original

        put "/v1/schools/#{school.external_identifier}/reinvite_partner",
             params: { person: person_params },
             headers: headers
        expect(response).to have_http_status(:success)
      end
    end

    context 'when the request is valid' do
      let(:status) { School::Status::EMERGING }

      it 'invites a partner and returns the updated school' do
        expect(SSJMailer).to receive(:invite_partner).and_call_original

        put "/v1/schools/#{school.external_identifier}/reinvite_partner",
             params: { person: person_params },
             headers: headers
        expect(response).to have_http_status(:success)
        expect(json_response['data']['id']).to eq(school.external_identifier)
      end
    end

    context 'when the request is invalid' do
      before do
        allow(School::ReinvitePartner).to receive(:run).and_raise(StandardError, 'Something went wrong')
      end

      it 'returns an error message' do
        Bullet.enable = false
        put "/v1/schools/#{school.external_identifier}/reinvite_partner",
             params: { person: person_params },
             headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Something went wrong')
        Bullet.enable = true
      end
    end
  end

  describe 'PUT v1/schools/:school_id/remove_partner' do
    let(:user) { create(:user, :admin) }
    let(:school) { create(:school) }
    let(:person) { create(:person) }
    let!(:school_relationship) { create(:school_relationship, person:, school:, start_date: Date.today, end_date: nil) }
    let(:person_params) { { id: person.external_identifier } }

    context 'when the request is valid' do
      it 'removes the partner and returns the updated school' do
        put "/v1/schools/#{school.external_identifier}/remove_partner",
            params: { person: person_params },
            headers: headers
        expect(response).to have_http_status(:success)
        expect(school.reload.school_relationships.active).not_to include(school_relationship)
        expect(school.reload.active_partners).not_to include(person)
      end
    end

    context 'when the request is invalid' do
      before do
        allow(School::RemovePartner).to receive(:run).and_raise(StandardError, 'Something went wrong')
      end

      it 'returns an error message' do
        put "/v1/schools/#{school.external_identifier}/remove_partner",
            params: { person: person_params },
            headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Something went wrong')
      end
    end
  end

  describe 'DELETE /v1/schools/:id' do
    let(:user) { create(:user, :admin) }

    context 'when the school exists' do
      it 'removes the school and returns a success message' do
        expect(School::Remove).to receive(:run).with(school).once

        delete "/v1/schools/#{school.external_identifier}", headers: headers

        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)).to eq({ 'message' => "school #{school.external_identifier} deleted" })
      end
    end

    context 'when the school does not exist' do
      it 'returns an error message' do
        delete '/v1/schools/nonexistent', headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('message')
      end
    end
  end
end
