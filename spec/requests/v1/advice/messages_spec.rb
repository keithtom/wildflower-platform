require 'rails_helper'

RSpec.describe "V1::Advice::Messages", type: :request do
  let!(:decision) { create(:advice_decision) }
  let!(:message) { create(:advice_message, decision: decision) }

  before do
    create(:advice_message, decision: decision)
  end

  describe "GET /v1/advice/decisions/1/messages" do
    it "succeeds" do
      get "/v1/advice/decisions/#{decision.id}/messages", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # should only have all messages
    end
  end

  # you don't create a message in the context of a stakeholder
  # you create messages for a decision
  # the "thread/channel" is determined by recipient.
  # eventually ppl will want to open up.  messages should be similar to email infrastucture with threads
  describe "POST /v1/advice/decisions/1/messages" do

    it "succeeds" do
      post "/v1/advice/decisions/#{decision.id}/messages", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # create message for decision
    end
  end

  describe "PUT /v1/advice/decisions/1/messages/1" do
    it "succeeds" do
      put "/v1/advice/decisions/#{decision.id}/messages/#{message.id}", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # update the message if recent
    end
  end

  describe "DELETE /v1/advice/decisions/1/messages/1" do
    it "succeeds" do
      put "/v1/advice/decisions/#{decision.id}/messages/#{message.id}", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
      # delete the message if recent
    end
  end
end
