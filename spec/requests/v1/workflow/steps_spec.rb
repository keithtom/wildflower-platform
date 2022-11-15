RSpec.describe "V1::Workflow::Steps", type: :request do
  let(:process) { create(:process) }
  let(:step) { create(:step, process_id: process.id) }

  describe "GET /v1/workflow/processes/6982-2091/steps/bd8f-c3b2" do
    it "succeeds" do
      get "/v1/workflow/processes/#{process.external_identifier}/steps/#{step.external_identifier}", headers: {'ACCEPT' => 'application/json'}
      expect(response).to have_http_status(:success)
      expect(json_response['data']).to include(have_type('step').and have_attribute(:title) )
      # expect(json_response['data'][0]['relationships'].keys).to include("creator", "stakeholders", "documents")
      # expect(json_response['included']).to include(have_type('stakeholder'))
      # expect(json_response['included']).to include(have_type('document'))
      # expect(json_response['data'].size).to eql(4)
    end
  end
end
