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

  describe "GET /v1/people/1" do
    it "succeeds" do
      get "/v1/people/#{Person.first.external_identifier}", headers: { 'ACCEPT' => 'application/json'}
      expect(response).to have_http_status(:success)
    end
  end
end
