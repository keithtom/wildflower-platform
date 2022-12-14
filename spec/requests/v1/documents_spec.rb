require 'rails_helper'

RSpec.describe "V1::Documents", type: :request do
  let(:decision) { create(:advice_decision) }
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe "POST /v1/documents" do
    it "succeeds" do
      post "/v1/documents", headers: {'ACCEPT' => 'application/json' }, params: { document: { documentable_id: decision.external_identifier, link: "https://www.google.com" } }
      expect(response).to have_http_status(:created)
    end
  end

  describe "DELETE /v1/documents/1" do
    it "succeeds" do
      document = create(:document, :documentable => decision)
      delete "/v1/documents/#{document.external_identifier}", headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)
    end
  end
end
