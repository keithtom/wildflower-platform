require 'rails_helper'

RSpec.describe "V1::Advice::Stakeholders", type: :request do
  let!(:decision) { create(:open_advice_decision) }
  let!(:stakeholder) { create(:advice_stakeholder, decision: decision) }
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe "GET /v1/advice/decisions/1/stakeholders" do
    it "succeeds" do
      get "/v1/advice/decisions/#{decision.id}/stakeholders", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # should only have all stakeholders
    end
  end

  describe "POST /v1/advice/decisions/1/stakeholders" do
    it "succeeds" do
      post "/v1/advice/decisions/#{decision.id}/stakeholders", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # creates a new stkaeholder for decision
    end
  end

  describe "DELETE /v1/advice/decisions/1/stakeholders/1" do
    it "succeeds" do
      delete "/v1/advice/decisions/#{decision.id}/stakeholders/#{stakeholder.id}", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # removes stkaeholder for decision
    end
  end

  describe "POST /v1/advice/decisions/1/stakeholders/1/records" do
    it "succeeds" do
      post "/v1/advice/decisions/#{decision.id}/stakeholders/#{stakeholder.id}/records", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # creates a record from the stakeholder
    end
  end
end
