require 'rails_helper'

describe 'API V1 School', type: :request do
  before do
    create(:school)
    create(:school)
  end

  describe "GET /api/v1/schools" do
    it "succeeds" do
      get "/api/v1/schools", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /api/v1/schools/1" do
    it "succeeds" do
      get "/api/v1/schools/#{School.first.external_identifier}", headers: { 'ACCEPT' => 'application/json'}
      expect(response).to have_http_status(:success)
    end
  end
end