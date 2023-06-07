require 'rails_helper'

RSpec.describe "V1::Searches", type: :request do
  describe "GET /index", search: true do
    let!(:person1) { create(:person, first_name: "Keith") }
    let!(:school1) { create(:school, name: "Keith Montessori") }
    before do
      Person.reindex
      School.reindex
    end

    it "succeeds for people" do
      get "/v1/search", params: { q: "Keith", models: "person" }, headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)

      expect(json_response['data']).to include(have_type('person').and have_attribute(:firstName).with_value('Keith'))
    end

    it "succeeds for schools" do
      get "/v1/search", params: { q: "Keith", models: "school"}, headers: {'ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:success)

      expect(json_response['data']).to include(have_type('school').and have_attribute(:name).with_value('Keith Montessori'))
    end
  end
end
