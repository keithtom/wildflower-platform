require 'rails_helper'

RSpec.describe V1::Admin::SSJController, type: :request do
  describe '#invite_team' do
    let(:ops_guide_user) { create(:user, :with_person) }
    let(:rgl_user) { create(:user, :with_person) }
    let(:ops_guide) { ops_guide_user.person }
    let(:rgl) { rgl_user.person }
    let(:etl_people_params) {[
      { first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email }, 
      { first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email }
    ]}
    let(:headers) { {'ACCEPT' => 'application/json'} }
    let(:user) {create(:user, :admin) }
    let(:etl_params_controller) { 
      ActionController::Parameters.new({:team => {:etl_people_params => etl_people_params}}).require(:team).permit([:etl_people_params => [:first_name, :last_name, :email]])
    }

    before do
      sign_in(user)
    end

    context 'when an admin makes the request' do
      before do
        allow(controller).to receive(:authenticate_admin!).and_return(true)
        allow(Person).to receive(:find_by!).with(external_identifier: ops_guide.external_identifier).and_return(ops_guide)
        allow(Person).to receive(:find_by!).with(external_identifier: rgl.external_identifier).and_return(rgl)
        allow(SSJ::InviteTeam).to receive(:run).with(etl_params_controller[:etl_people_params], ops_guide, rgl).and_return(team)
      end

      context 'when the team is successfully invited' do
        let(:team) { create(:ssj_team, ops_guide: ops_guide, regional_growth_lead: rgl) }

        it 'returns a success message' do
          put "/v1/admin/ssj/invite_team", params: { team: { ops_guide_id: ops_guide.external_identifier, rgl_id: rgl.external_identifier, etl_people_params: etl_people_params }}, headers: headers
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq({ 'message' => "team #{team.external_identifier} invite emails sent" })
        end
      end

      context 'when inviting the team fails' do
        let(:error_message) { 'Something went wrong' }
        let(:team) { nil }

        before do
          allow(SSJ::InviteTeam).to receive(:run).and_raise(error_message)
        end

        it 'returns an error message' do
          put "/v1/admin/ssj/invite_team", params: { team: { ops_guide_id: ops_guide.external_identifier, rgl_id: rgl.external_identifier, etl_people_params: etl_people_params }}, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to eq({ 'message' => error_message })
        end
      end
    end

    context 'when a non-admin makes the request' do
      before do
        allow(user).to receive(:is_admin).and_return(false)
      end

      it 'returns an unauthorized error message' do
        put "/v1/admin/ssj/invite_team", params: { team: { ops_guide_id: ops_guide.external_identifier, rgl_id: rgl.external_identifier, etl_people_params: etl_people_params }}, headers: headers
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ 'message' => 'Unauthorized' })
      end
    end
  end
end