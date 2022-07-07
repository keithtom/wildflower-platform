require 'rails_helper'

RSpec.describe "V1::Advice::Decisions", type: :request do
  let(:creator) { create(:person) }
  let!(:decision) { create(:open_advice_decision, creator: creator) }

  before do
    create(:advice_decision)
    create(:draft_advice_decision, creator: creator)
    create(:open_advice_decision, creator: creator)
    create(:closed_advice_decision, creator: creator)
  end

  describe "GET /v1/advice/people/1/decisions" do
    it "succeeds" do
      get "/v1/advice/people/#{creator.external_identifier}/decisions", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      expect(json_response['data']).to include(have_type('decision').and have_attribute(:title) )
      expect(json_response['data'][0]['relationships'].keys).to include("creator", "stakeholders", "documents")
      expect(json_response['included']).to include(have_type('stakeholder'))
      expect(json_response['included']).to include(have_type('document'))
      expect(json_response['data'].size).to eql(4)
    end
  end

  describe "GET /v1/advice/people/1/decisions/draft" do
    it "succeeds" do
      get "/v1/advice/people/#{creator.external_identifier}/decisions/draft", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # should only have draft advice decisions
    end
  end

  describe "GET /v1/advice/people/1/decisions/open" do
    it "succeeds" do
      get "/v1/advice/people/#{creator.external_identifier}/decisions/open", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # should only have open advice decisions
    end
  end

  describe "GET /v1/advice/people/1/decisions/closed" do
    it "succeeds" do
      get "/v1/advice/people/#{creator.external_identifier}/decisions/closed", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # should only have closed advice decisions
    end
  end

  describe "POST /v1/advice/decisions" do
    it "succeeds" do
      person = create(:person, external_identifier: "2a09-fba2") # Normally need to auth here.
      post "/v1/advice/decisions", headers: {'ACCEPT' => 'application/json' }, params: { decision: { title: "New Title"} }
      expect(response).to have_http_status(:success)
      expect(Advice::Decision.last.title).to be == "New Title"
    end
  end

  describe "GET /v1/advice/decisions/1" do
    it "succeeds" do
      get "/v1/advice/decisions/#{decision.external_identifier}", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      expect(json_response['data']).to have_type('decision').and have_attribute(:title)
    end
  end

  describe "PUT /v1/advice/decisions/1" do
    it "succeeds" do
      put "/v1/advice/decisions/#{decision.external_identifier}", headers: {'ACCEPT' => 'application/json' }, params: { decision: { title: "New Title"} }
      expect(response).to have_http_status(:success)
      expect(decision.reload.title).to be == "New Title"
    end
  end

  describe "PUT /v1/advice/decisions/1/open" do
    it "succeeds" do
      put "/v1/advice/decisions/#{decision.external_identifier}/open", headers: {'ACCEPT' => 'application/json' }, params: { decision: { decide_by: 14.days.from_now, advice_by: 7.days.from_now } }
      expect(response).to have_http_status(:success)
      expect(decision.reload.state).to be == Advice::Decision::OPEN
    end
  end

  describe "PUT /v1/advice/decisions/1/close" do
    it "succeeds" do
      put "/v1/advice/decisions/#{decision.external_identifier}/close", headers: {'ACCEPT' => 'application/json' }, params: { decision: { final_summary: "Hi!" } }
      expect(response).to have_http_status(:success)
      expect(decision.reload.state).to be == Advice::Decision::CLOSED
    end
  end

  describe "PUT /v1/advice/decisions/1/amend" do
    it "succeeds" do
      put "/v1/advice/decisions/#{decision.external_identifier}/amend", headers: {'ACCEPT' => 'application/json' }
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
