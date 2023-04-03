require 'rails_helper'

describe 'API V1 People', type: :request do
  let(:user) { create(:user) }

  before do
    create(:person)
    create(:person)
    sign_in(user)
  end

  describe "GET /v1/people" do
    it "succeeds" do
      get "/v1/people", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /v1/people/search", search: true do
    let!(:person1) { create(:person, first_name: "Keith") }
    # before { Person.reindex }

    xit "succeeds" do
      get "/v1/people/search", params: { search: {q: "Keith"} }, headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)

      expect(json_response['data']).to include(have_type('person').and have_attribute(:firstName).with_value('Keith'))
    end
  end

  describe "GET /v1/people/1" do
    xit "succeeds" do
      get "/v1/people/#{Person.first.external_identifier}", headers: { 'ACCEPT' => 'application/json'}
      expect(response).to have_http_status(:success)
    end
  end
end
