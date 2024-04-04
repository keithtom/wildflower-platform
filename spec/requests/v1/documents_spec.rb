require 'rails_helper'

RSpec.describe V1::DocumentsController, type: :request do
  let(:decision) { create(:advice_decision) }
  let(:user) { create(:user) }

  describe "POST /v1/documents" do
    context "authenticated as as regular user" do
      before do
        sign_in(user)
      end

      it "succeeds" do
        post "/v1/documents", headers: {'ACCEPT' => 'application/json' }, params: { document: { documentable_id: decision.external_identifier, link: "https://www.google.com" } }
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "DELETE /v1/documents/1" do
    context "when authenticated as admin" do
      let(:admin) { create(:user, :admin) }

      before do
        sign_in(admin)
      end

      it "succeeds" do
        document = create(:document, :documentable => decision)
        delete "/v1/documents/#{document.id}", headers: {'ACCEPT' => 'application/json' }
        expect(response).to have_http_status(:success)
      end
    end
  end
end
