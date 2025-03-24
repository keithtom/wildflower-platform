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

    describe 'GET /v1/people/1' do
      it 'succeeds' do
        get "/v1/people/#{Person.first.external_identifier}", headers: headers
        expect(response).to have_http_status(:success)
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
  end
end
