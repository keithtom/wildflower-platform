require 'rails_helper'

RSpec.describe V1::SSJ::TeamsController, type: :request do
  let(:ops_guide_user) { create(:user, :with_person) }
  let(:rgl_user) { create(:user, :with_person) }
  let(:ops_guide) { ops_guide_user.person }
  let(:rgl) { rgl_user.person }
  let(:etl_people_params) {[
    { first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email }, 
    { first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email }
  ]}
  let(:headers) { {'ACCEPT' => 'application/json'} }
  let(:etl_params_controller) { 
    ActionController::Parameters.new({:team => {:etl_people_params => etl_people_params}}).require(:team).permit([:etl_people_params => [:first_name, :last_name, :email]])
  }

  describe 'POST #create' do
    let(:user) {create(:user, :admin) }

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
          post "/v1/ssj/teams", params: { team: { ops_guide_id: ops_guide.external_identifier, rgl_id: rgl.external_identifier, etl_people_params: etl_people_params }}, headers: headers
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
          post "/v1/ssj/teams", params: { team: { ops_guide_id: ops_guide.external_identifier, rgl_id: rgl.external_identifier, etl_people_params: etl_people_params }}, headers: headers
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
        post "/v1/ssj/teams", params: { team: { ops_guide_id: ops_guide.external_identifier, rgl_id: rgl.external_identifier, etl_people_params: etl_people_params }}, headers: headers
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq({ 'message' => 'Unauthorized' })
      end
    end
  end

  describe "GET #index" do
    let(:user) {create(:user) }

    before do
      sign_in(user)
    end

    it "returns a successful response with a list of teams" do
      team1 = create(:ssj_team_with_members)
      team2 = create(:ssj_team_with_members)
      get "/v1/ssj/teams", headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq(JSON.parse(V1::SSJ::TeamSerializer.new([team1, team2]).to_json))
    end
  end

  context "existing team" do
    let(:workflow) { create(:workflow_instance_workflow) }
    let(:person) { create(:person) }
    let(:user) { create(:user, person_id: person.id) }
    let!(:step) { create(:workflow_instance_step) }
    # let!(:decision_step) { create(:workflow_instance_step, :decision) }
    let(:workflow) { step.process.workflow }
    let(:expected_start_date) { Date.today + 7.days }
    let(:phase) { SSJ::Phase::PHASES.first }
    let(:team) { person.ssj_team }

    before do
      sign_in(user)
      team = SSJ::Team.new(expected_start_date: expected_start_date)
      team.workflow = workflow
      team.save!
      SSJ::TeamMember.create!(ssj_team: team, person: person, status: SSJ::TeamMember::ACTIVE, role: SSJ::TeamMember::PARTNER)
      p = step.definition.process
      p.category_list << "Finance"
      p.category_list << "Human Resources"
      p.category_list << "unknown category"
      p.save!
      step.assignments.create!(assignee: person)
      p.phase_list << phase
      p.save!
    end

    describe "GET #show" do
      it "succeeds" do
        get "/v1/ssj/teams/#{team.external_identifier}", headers: headers
        expect(response).to have_http_status(:success)
        puts json_response
        expect(json_response["data"]["attributes"]["hasPartner"]).to be false
        expect(json_response["data"]["attributes"]["expectedStartDate"]).to eq(expected_start_date.to_formatted_s("yyyy-mm-dd"))
      end
    end

    describe "PUT #update" do
      let(:new_start_date) { "2023-03-01" }

      it "succeeds" do
        put "/v1/ssj/teams/#{team.external_identifier}", headers: headers, params: { team: { expected_start_date: new_start_date }}
        expect(response).to have_http_status(:success)
        expect(json_response["data"]["attributes"]["expectedStartDate"]).to eq(new_start_date)
        ssj_team = SSJ::TeamMember.find_by(person_id: user.person_id).ssj_team
        expect(ssj_team.reload.expected_start_date.to_formatted_s("yyyy-mm-dd")).to eq(new_start_date)
      end
    end
  end
end