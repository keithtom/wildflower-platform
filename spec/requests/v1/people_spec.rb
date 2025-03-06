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
