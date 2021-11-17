require 'rails_helper'

describe 'API V1 People', type: :request do
  before do
    create(:person)
    create(:person)
  end

  describe "GET /api/v1/people" do
    it "succeeds" do
      get "/api/v1/people", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /api/v1/people/1" do
    it "succeeds" do
      get "/api/v1/people/#{Person.first.external_identifier}", headers: { 'ACCEPT' => 'application/json'}
      expect(response).to have_http_status(:success)
    end
  end
end