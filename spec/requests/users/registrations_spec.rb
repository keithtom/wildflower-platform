require 'rails_helper'

RSpec.describe "Users::Registrations", type: :request do
  let(:headers) { {'ACCEPT' => 'application/json'} }
  let(:email) { Faker::Internet.unique.email  }
  let(:user) { create(:user) }

  describe "POST /signup" do
    it "succeeds" do
      post "/signup", headers: headers, params: { user: { email: email, password: "password" }}
      expect(response).to have_http_status(:success)
      expect(User.last.email).to eq(email)
    end
  end

  describe "POST /users/email_login" do
    context "when the email exists in the system" do
      it "sends an email with a login link" do
        post "/users/email_login", params: { email: user.email }
        expect(response).to have_http_status(:success)
        expect(ActionMailer::Base.deliveries.last.to).to eq [user.email]
        expect(ActionMailer::Base.deliveries.last.subject).to include("Login to the School Startup")
      end
    end

    context "when the email does not exist in the system" do
      it "returns an error message" do
        post "/users/email_login", params: { email: "nonexistent_email@example.com" }
        expect(response).to have_http_status(:success)
      end
    end
  end
end
