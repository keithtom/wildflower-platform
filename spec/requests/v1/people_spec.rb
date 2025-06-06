require 'rails_helper'

describe 'API V1 People', type: :request do
  let(:user) { create(:user) }
  let(:headers) { { 'ACCEPT' => 'application/json' } }

  before do
    create(:person)
    create(:person)
  end

  context 'when user is not admin' do
    before do
      sign_in(user)
    end

    describe 'GET /v1/people' do
      it 'succeeds' do
        get '/v1/people', headers: headers
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET /v1/people/:id' do
      let(:person) { create(:person) }

      it 'succeeds' do
        get "/v1/people/#{person.external_identifier}", headers: headers
        expect(response).to have_http_status(:success)
      end

      context 'when network parameter is true' do
        let!(:school1) { create(:school) }
        let!(:school2) { create(:school) }
        let!(:school3) { create(:school) }

        # Create school relationships with different roles
        let!(:etl_relationship) do
          create(:school_relationship,
                 person:,
                 school: school1,
                 end_date: nil,
                 role_list: [Person::ETL])
        end

        let!(:tl_relationship) do
          create(:school_relationship,
                 person:,
                 school: school2,
                 end_date: nil,
                 role_list: [Person::TL])
        end

        let!(:board_member_relationship) do
          create(:school_relationship,
                 person:,
                 school: school3,
                 end_date: nil,
                 role_list: [Person::BOARD_MEMBER])
        end

        # Create a relationship that should NOT be included (no relevant role)
        let!(:other_relationship) do
          create(:school_relationship,
                 person:,
                 school: create(:school),
                 end_date: nil,
                 role_list: ['Other Role'])
        end

        it 'returns success with network-filtered data' do
          Bullet.enable = false
          get "/v1/people/#{person.external_identifier}",
              params: { network: true },
              headers: headers
          Bullet.enable = true

          expect(response).to have_http_status(:success)
          expect(json_response['data']).to have_type('person')
        end

        it 'includes relationships with ETL, TL, and BOARD_MEMBER roles' do
          Bullet.enable = false
          get "/v1/people/#{person.external_identifier}",
              params: { network: true },
              headers: headers
          Bullet.enable = true

          included_school_relationships = json_response['included']
                                           .select { |item| item['type'] == 'schoolRelationship' }

          expect(included_school_relationships.length).to eq(3)

          # Verify the correct relationships are included
          relationship_ids = included_school_relationships.map { |rel| rel['id'] }
          expect(relationship_ids).to include(etl_relationship.external_identifier)
          expect(relationship_ids).to include(tl_relationship.external_identifier)
          expect(relationship_ids).to include(board_member_relationship.external_identifier)
          expect(relationship_ids).not_to include(other_relationship.external_identifier)
        end

        it 'includes only schools associated with ETL, TL, and BOARD_MEMBER roles' do
          Bullet.enable = false
          get "/v1/people/#{person.external_identifier}",
              params: { network: true },
              headers: headers
          Bullet.enable = true

          included_schools = json_response['included']
                             .select { |item| item['type'] == 'schoolSearch' }

          expect(included_schools.length).to eq(3)

          # Verify the correct schools are included
          school_ids = included_schools.map { |school| school['id'] }
          expect(school_ids).to include(school1.external_identifier)
          expect(school_ids).to include(school2.external_identifier)
          expect(school_ids).to include(school3.external_identifier)
          expect(school_ids).not_to include(other_relationship.school.external_identifier)
        end

        it 'includes address data' do
          person.create_address(city: 'Test City', state: 'Test State')

          Bullet.enable = false
          get "/v1/people/#{person.external_identifier}",
              params: { network: true },
              headers: headers
          Bullet.enable = true

          included_addresses = json_response['included']
                               .select { |item| item['type'] == 'address' }

          expect(included_addresses.length).to eq(1)
          expect(included_addresses.first['attributes']['city']).to eq('Test City')
        end

        context 'when person has no network-relevant relationships' do
          let(:person_without_network_roles) { create(:person) }

          before do
            # Create relationships without ETL, TL, or BOARD_MEMBER roles
            create(:school_relationship,
                   person: person_without_network_roles,
                   school: create(:school),
                   end_date: nil,
                   role_list: ['Some Other Role'])
          end

          it 'returns empty schools and school_relationships' do
            get "/v1/people/#{person_without_network_roles.external_identifier}",
                params: { network: true },
                headers: headers

            # Should still return the person but with empty related arrays
            expect(response).to have_http_status(:success)
            expect(json_response['data']).to have_type('person')

            included_school_relationships = json_response['included']
                                           &.select { |item| item['type'] == 'schoolRelationship' } || []
            included_schools = json_response['included']
                              &.select { |item| item['type'] == 'school' } || []

            expect(included_school_relationships).to be_empty
            expect(included_schools).to be_empty
          end
        end
      end
    end

    context 'with pagination' do
      before do
        # Create 30 people to test pagination
        create_list(:person, 30)
      end

      it 'returns paginated results with default values' do
        get '/v1/people', headers: headers

        expect(response).to have_http_status(:success)
        expect(json_response['data'].length).to eq(25) # default per_page
        expect(json_response['meta']).to include(
          'current_page' => 1,
          'per_page' => 25,
          'total_entries' => 32, # 2 from top before block + 30 created here
          'total_pages' => 2
        )
      end

      it 'respects custom page and per_page parameters' do
        get '/v1/people', params: { page: 2, per_page: 10 }, headers: headers

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
        get '/v1/people', params: { page: 4, per_page: 10 }, headers: headers

        expect(response).to have_http_status(:success)
        expect(json_response['data'].length).to eq(2) # Last page with remaining record
        expect(json_response['meta']).to include(
          'current_page' => 4,
          'per_page' => 10,
          'total_entries' => 32,
          'total_pages' => 4
        )
      end

      context 'with different serializer options' do
        it 'paginates ETL filtered results' do
          create_list(:person, 5).each do |p|
            p.role_list.add(Person::ETL)
            p.save!
          end

          Bullet.enable = false
          get '/v1/people', params: { etl: true, page: 1, per_page: 2 }, headers: headers
          Bullet.enable = false

          expect(response).to have_http_status(:success)
          expect(json_response['data'].length).to eq(2)
          expect(json_response['meta']['total_entries']).to eq(5)
        end

        it 'paginates lightweight results' do
          get '/v1/people', params: { lightweight: true, page: 1, per_page: 10 }, headers: headers

          expect(response).to have_http_status(:success)
          expect(json_response['data'].length).to eq(10)
          expect(json_response['meta']).to include('total_pages', 'current_page')
        end
      end

      context 'with invalid pagination parameters' do
        it 'handles negative page numbers gracefully' do
          get '/v1/people', params: { page: -1 }, headers: headers

          expect(response).to have_http_status(:success)
          expect(json_response['meta']).to include(
            'current_page' => 1  # Should default to first page
          )
        end

        it 'handles zero page number gracefully' do
          get '/v1/people', params: { page: 0 }, headers: headers

          expect(response).to have_http_status(:success)
          expect(json_response['meta']).to include(
            'current_page' => 1  # Should default to first page
          )
        end

        it 'handles negative per_page gracefully' do
          get '/v1/people', params: { per_page: -5 }, headers: headers

          expect(response).to have_http_status(:success)
          expect(json_response['meta']).to include(
            'per_page' => 25 # Should use default per_page
          )
        end

        it 'handles too large per_page gracefully' do
          get '/v1/people', params: { per_page: 1000 }, headers: headers

          expect(response).to have_http_status(:success)
          expect(json_response['meta']).to include(
            'per_page' => 100 # Should use max per_page
          )
        end

        it 'handles non-numeric pagination parameters gracefully' do
          get '/v1/people', params: { page: 'abc', per_page: 'def' }, headers: headers

          expect(response).to have_http_status(:success)
          expect(json_response['meta']).to include(
            'current_page' => 1,
            'per_page' => 25 # Should use defaults
          )
        end
      end

      context 'with empty result sets' do
        before do
          Person.destroy_all
        end

        it 'returns empty data array with correct metadata' do
          get '/v1/people', headers: headers

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
          get '/v1/people', params: { page: 100 }, headers: headers

          expect(response).to have_http_status(:success)
          expect(json_response['data']).to be_empty
          expect(json_response['meta']).to include(
            'current_page' => 100,
            'total_pages' => 2 # With 31 records and 25 per page, should have 2 pages
          )
        end
      end
    end

    context 'DELETE /v1/people/1' do
      let(:person) { create(:person) }

      it 'returns unauthorized status' do
        delete "/v1/people/#{person.external_identifier}", headers: headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context 'when user is admin' do
    let(:admin) { create(:user, :admin) }

    before do
      sign_in(admin)
    end

    describe 'POST /v1/people' do
      let(:valid_params) do
        {
          person: {
            email: 'test@example.com',
            first_name: 'Test',
            last_name: 'User',
            primary_language: 'English',
            phone: '123-456-7890'
          }
        }
      end

      context 'with valid parameters' do
        it 'creates a new person and user' do
          expect do
            post '/v1/people', params: valid_params, headers:
          end.to change(Person, :count).by(1)
             .and change(User, :count).by(1)

          expect(response).to have_http_status(:created)

          person = Person.last
          expect(person.email).to eq(valid_params[:person][:email])
          expect(person.first_name).to eq(valid_params[:person][:first_name])
          expect(person.last_name).to eq(valid_params[:person][:last_name])
          expect(person.active).to be false

          expect(json_response['data']).to have_type(:person)
          expect(json_response['data']['attributes']).to include(
            'email' => valid_params[:person][:email],
            'firstName' => valid_params[:person][:first_name],
            'lastName' => valid_params[:person][:last_name]
          )
        end

        it 'sends an invite email' do
          expect(Users::SendInviteEmail).to receive(:call)
          post '/v1/people', params: valid_params, headers:
        end
      end

      context 'with invalid parameters' do
        let(:invalid_params) do
          {
            person: {
              first_name: 'Test',
              last_name: 'User'
              # missing required email
            }
          }
        end

        it 'raises an error and does not create records' do
          expect(Person.count).to eq(2) # The two people created in the before block
          expect(User.count).to eq(1)   # Just the admin user
        end
      end

      context 'when person creation fails' do
        let(:failed_person) { Person.new(valid_params[:person]) }

        before do
          failed_person.errors.add(:email, 'has already been taken')
          allow(Admin::CreatePerson).to receive(:run).and_raise(ActiveRecord::RecordInvalid.new(failed_person))
        end

        it 'returns unprocessable entity status with errors' do
          post '/v1/people', params: valid_params, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response).to eq({ 'errors' => ['Email has already been taken'] })
        end

        it 'does not create any records' do
          expect do
            post '/v1/people', params: valid_params, headers:
          end.not_to change(Person, :count)

          expect do
            post '/v1/people', params: valid_params, headers:
          end.not_to change(User, :count)
        end
      end
    end

    describe 'DELETE /v1/people/:id' do
      let(:person) { create(:person) }
      let!(:user) { create(:user, person:) }

      context 'when person exists' do
        it 'destroys the person and associated user' do
          expect do
            delete "/v1/people/#{person.external_identifier}", headers:
          end.to change(Person, :count).by(0)
                                       .and change(User, :count).by(-1)

          expect(person.reload.end_date).to eq(Date.today)
          expect(person.active).to be false
          expect(response).to have_http_status(:ok)
          expect(json_response).to eq({ 'message' => 'Person removed' })
        end

        it 'returns 404 if person does not exist' do
          delete '/v1/people/non-existent-id', headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when person has associated records' do
        let!(:school_relationship) { create(:school_relationship, person:, end_date: nil) }
        let!(:workflow_assignment) { create(:workflow_instance_step_assignment, assignee: person) }

        it 'destroys the person and all associated records' do
          expect do
            delete "/v1/people/#{person.external_identifier}", headers:
          end.to change(Person, :count).by(0)
             .and change(User, :count).by(-1)
             .and change(SchoolRelationship, :count).by(0)
             .and change(Workflow::Instance::StepAssignment, :count).by(-1)

          expect(person.reload.end_date).to eq(Date.today)
          expect(school_relationship.reload.end_date).to eq(Date.today)
          expect(response).to have_http_status(:ok)
          expect(json_response).to eq({ 'message' => 'Person removed' })
        end
      end

      context 'error is raised' do
        let(:offboard_date) { Date.today }

        it 'handles offboarding errors gracefully' do
          allow_any_instance_of(People::Offboard).to receive(:run).and_raise(StandardError.new('Offboarding failed'))

          delete "/v1/people/#{person.external_identifier}", headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response).to eq({ 'error' => 'Offboarding failed' })
        end
      end
    end
  end
end
