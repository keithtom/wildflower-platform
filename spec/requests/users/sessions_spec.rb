require 'rails_helper'

RSpec.describe "Users::Sessions", type: :request do
  let(:headers) { {'ACCEPT' => 'application/json'} }
  let(:user) { create(:user, password: "password")}

  describe "POST /login and DELETE /logout" do
    it "succeeds" do
      post "/login", headers: headers, params: { user: { email: user.email, password: "password" }}
      expect(response).to have_http_status(:success)

      token = response.headers["Authorization"]
      decoded_token = JWT.decode(token.split[1], nil, false)[0]
      expect(decoded_token["sub"]).to eq(user.external_identifier)

      headers['Authorization'] = token
      delete "/logout", headers: headers
      expect(response).to have_http_status(:success)
    end
  end

#   describe "POST /logout" do
#     it "succeeds" do
#       post "/logout", headers: headers, params: { user: { email: user.email, password: "password" }}
#       expect(response).to have_http_status(:success)
#     end
#   end
end
