require 'rails_helper'

describe 'API V1 School', type: :request do
  let(:user) { create(:user) }

  before do
    create(:school)
    create(:school)
    sign_in(user)
  end

  describe "GET /v1/schools" do
    it "succeeds" do
      get "/v1/schools", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /v1/schools/1" do
    it "succeeds" do
      get "/v1/schools/#{School.first.external_identifier}", headers: { 'ACCEPT' => 'application/json'}
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT /v1/schools/1" do
    let(:person1) { create(:person) }
    let(:person2) { create(:person) }
    let(:person3) { create(:person) }
    let(:school) { School.first }

    it "succeeds" do
      put "/v1/schools/#{school.external_identifier}", 
      params: { school: { 
        about: 'new about',
        school_relationships_attributes: [
          { person_id: person1.id },
          { person_id: person2.id },
          { person_id: person3.id },
      ],
        address_attributes: {
          city: 'new city',
          state: 'new state',
        },
        opened_on: '2018-01-01',
        ages_served_list: ['elementary', 'middle'],
        governance_type: 'charter',
        max_enrollment: 100
      } }, 
      headers: { 'ACCEPT' => 'application/json'}
      expect(response).to have_http_status(:success)

      school.reload
      expect(school.address.city).to eq('new city')
      expect(school.people).to include(person1, person2, person3)
      expect(school.ages_served_list).to eq(['elementary', 'middle'])
    end
  end
end
