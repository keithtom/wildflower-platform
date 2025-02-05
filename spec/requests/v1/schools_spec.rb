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
        get '/v1/schools', headers: { 'ACCEPT' => 'application/json' }
        expect(response).to have_http_status(:success)
      end

      describe 'with person_id query parameter' do
        it 'succeeds' do
          get "/v1/schools?person_id=#{person.external_identifier}", headers: { 'ACCEPT' => 'application/json' }
          expect(response).to have_http_status(:success)
          expect(json_response['data'].first['id']).to eq(school.external_identifier)
        end
      end

      describe 'with person_id query parameter' do
        it 'succeeds' do
          get "/v1/schools?person_id=#{person.external_identifier}&role=Ops%20Guide",
              headers: { 'ACCEPT' => 'application/json' }
          expect(response).to have_http_status(:success)
          expect(json_response['data']).to be_empty
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
        expect(school.ages_served_list).to eq(%w[elementary middle])
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

  describe 'POST /v1/schools/:school_id/invite_partner' do
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
end
