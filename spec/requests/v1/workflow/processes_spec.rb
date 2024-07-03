require 'rails_helper'

RSpec.describe "V1::Workflow::Processes", type: :request do
  let(:headers) { {'ACCEPT' => 'application/json'} }
  let(:person) { create(:person) }
  let(:workflow_definition) { create(:workflow_definition_workflow) }
  let(:workflow) { Workflow::Instance::Workflow.create!(definition: workflow_definition) }
  let(:process_definition) { Workflow::Definition::Process.create!(title: "file taxes", description: "pay taxes to the IRS") }
  let!(:process) { Workflow::Instance::Process.create!(definition: process_definition, workflow: workflow) }
  let(:user) { create(:user, person_id: person.id) }
  let!(:assigned_step) { create(:workflow_instance_step_manual, process_id: process.id) }
  let!(:assignment) { create(:workflow_instance_step_assignment, step: assigned_step, assignee: user.person)}  

  before do
    sign_in(user)
  end

  describe "GET /v1/processes/6823-2341" do
    it "succeeds" do
      Bullet.enable = false
      get "/v1/workflow/processes/#{process.external_identifier}", headers: headers
      expect(response).to have_http_status(:success)
      expect(json_response["data"]).to have_type(:process).and have_attribute(:status)
      expect(json_response["data"]).to have_type(:process).and have_attribute(:stepsCount)
      expect(json_response["data"]).to have_type(:process).and have_attribute(:completedStepsCount)
      step_obj = json_response["included"].select{|obj| obj["type"] == "step"}.last
      Bullet.enable = true
    end
  end

  describe 'GET /v1/workflow/workflows/:workflow_id/processes' do
    context 'when using within_timeframe and omit_include params' do
      let(:date) { Date.today.to_s }
      let!(:past_due_process) { 
        Workflow::Instance::Process.create!(
          definition: process_definition,
          workflow: workflow,
          suggested_start_date: 3.months.ago,
          due_date: 1.month.ago,
          completion_status: Workflow::Instance::Process.completion_statuses[:started]
        )
      }
      let!(:within_timeframe_incompleted_process) {
        Workflow::Instance::Process.create!(
          definition: process_definition,
          workflow: workflow,
          suggested_start_date: 3.months.ago,
          due_date: 1.month.from_now,
          completion_status: Workflow::Instance::Process.completion_statuses[:started]
        )
      }
      let!(:within_timeframe_completed_process) {
        Workflow::Instance::Process.create!(
          definition: process_definition,
          workflow: workflow,
          suggested_start_date: 3.months.ago,
          due_date: 1.month.from_now,
          completion_status: Workflow::Instance::Process.completion_statuses[:finished]
        )
      }
      let!(:future_process) {
        Workflow::Instance::Process.create!(
          definition: process_definition,
          workflow: workflow,
          suggested_start_date: 1.month.from_now,
          due_date: 2.months.from_now,
          completion_status: Workflow::Instance::Process.completion_statuses[:unstarted]
        )
      }

      it 'succeeds' do
        get "/v1/workflow/workflows/#{workflow.external_identifier}/processes?timeframe=#{date}&omit_include=true", headers: headers
        expect(response).to have_http_status(:success)
        process_ids = json_response['data'].map { |process| process['id'] }
        expect(process_ids).to include(past_due_process.external_identifier)
        expect(process_ids).to include(within_timeframe_incompleted_process.external_identifier)
        expect(process_ids).to include(within_timeframe_completed_process.external_identifier)
        expect(process_ids).not_to include(future_process.external_identifier)
      end
    end
  end
end
