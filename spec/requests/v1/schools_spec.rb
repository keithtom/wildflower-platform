require 'rails_helper'

describe 'API V1 School', type: :request do
  before do
    create(:school)
    create(:school)
  end

  describe "GET /v1/schools" do
    it "succeeds" do
      get "/v1/schools", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /v1/schools/search", search: true do
    let!(:school1) { create(:school, name: "Keith Montessori") }
    before { School.reindex }

    it "succeeds" do
      get "/v1/schools/search", params: { search: {q: "Keith"} }, headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)

      expect(json_response['data']).to include(have_type('school').and have_attribute(:name).with_value('Keith Montessori'))
    end
  end


  describe "GET /v1/schools/1" do
    it "succeeds" do
      get "/v1/schools/#{School.first.external_identifier}", headers: { 'ACCEPT' => 'application/json'}
      expect(response).to have_http_status(:success)
    end
  end
end
