require 'rails_helper'

RSpec.describe "V1::Workflow::DecisionOptions", type: :request do
  describe "DELETE /v1/workflow/decision_options/:id" do
    let(:step) { create(:workflow_definition_step)}
    let!(:decision_option) { Workflow::DecisionOption.create!(description: "choose one", decision: step)}
    let(:admin) { create(:user, :admin) }
    
    context "when authenticated as an admin" do
      before do
        sign_in(admin)
        delete "/v1/workflow/decision_options/#{decision_option.id}"
      end
      
      it "deletes the decision option" do
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to eq({ 'message' => 'Successfully deleted decision option' })
        expect { decision_option.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
    
    context "when not authenticated as an admin" do
      before do
        delete "/v1/workflow/decision_options/#{decision_option.id}"
      end
      
      it "returns unauthorized status" do
        expect(response).to have_http_status(401)
      end
    end
  end
end