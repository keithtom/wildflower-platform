require 'rails_helper'

RSpec.describe "Users::Registrations", type: :request do
  let(:headers) { {'ACCEPT' => 'application/json'} }
  let(:email) { Faker::Internet.unique.email  }

  describe "POST /signup" do
    it "succeeds" do
      post "/signup", headers: headers, params: { user: { email: email, password: "password" }}
      expect(response).to have_http_status(:success)
      expect(User.last.email).to eq(email)
    end
  end
end