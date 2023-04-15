
require 'rails_helper'

describe V1::Workflow::StepAssignmentSerializer do
  let(:assignment) { create(:workflow_instance_step_assignment) }

  let(:default_options) {
    { params: { basic: true},
      include: [:step, :assignee, :selected_option] }
  }
  
  subject { described_class.new(assignment, default_options).as_json }


  it "should serialize properly" do
    expect(json_document['data']).to have_relationships(:step, :assignee, :selectedOption)
    expect(json_document['data']).to have_jsonapi_attributes(:assignedAt, :completedAt)
  end
end
