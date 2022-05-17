require 'rails_helper'

RSpec.describe "V1::Advice::Decisions", type: :request do
  let(:creator) { create(:person) }

  before do
    create(:advice_decision)
    create(:advice_decision, creator: creator, state: Advice::Decision::DRAFT)
    create(:advice_decision, creator: creator, state: Advice::Decision::OPEN)
    create(:advice_decision, creator: creator, state: Advice::Decision::CLOSED)
  end

  describe "GET /v1/advice/people/1/decisions" do
    it "succeeds" do
      get "/v1/advice/people/#{creator.id}/decisions", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # should only have all advice decisions
    end
  end

  describe "GET /v1/advice/people/1/decisions/draft" do
    it "succeeds" do
      get "/v1/advice/people/#{creator.id}/decisions/draft", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # should only have draft advice decisions
    end
  end

  describe "GET /v1/advice/people/1/decisions/open" do
    it "succeeds" do
      get "/v1/advice/people/#{creator.id}/decisions/open", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # should only have open advice decisions
    end
  end

  describe "GET /v1/advice/people/1/decisions/closed" do
    it "succeeds" do
      get "/v1/advice/people/#{creator.id}/decisions/closed", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # should only have closed advice decisions
    end
  end

  describe "POST /v1/advice/decisions" do
    it "succeeds" do
      post "/v1/advice/decisions", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # creates the decision with attributes
    end
  end

  describe "GET /v1/advice/decisions/1" do
    let!(:decision) { create(:advice_decision) }

    it "succeeds" do
      get "/v1/advice/decisions/#{decision.id}", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # show the decision with attributes
    end
  end

  describe "PUT /v1/advice/decisions/1" do
    it "succeeds" do
      put "/v1/advice/decisions/1", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # updates the decision with attributes
    end
  end

  describe "PUT /v1/advice/decisions/1/open" do
    it "succeeds" do
      put "/v1/advice/decisions/1/open", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # opens decision
    end
  end

  describe "PUT /v1/advice/decisions/1/close" do
    it "succeeds" do
      put "/v1/advice/decisions/1/close", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # closes the decision with attributes
    end
  end

  describe "PUT /v1/advice/decisions/1/amend" do
    it "succeeds" do
      put "/v1/advice/decisions/1/amend", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # should insert event, and record difference, new dates?, and null out people's records
      # requests advice again for the decision with attributes
    end
  end
end

# create commands/services for open close request create, update, destroy
#

# integration test is
# see drafts, create new draft, see it, update it, see/add/remove stakeholders
# open advice
# add messages in stakeholder chat (update, remove if recent)
# add records for stakeholders
# close advice

# test request advice again path.
