
require 'rails_helper'

describe V1::Workflow::StepAssignmentSerializer do
  let(:assignment) { create(:workflow_instance_step_assignment) }

  let(:default_options) {
    { params: { current_user: create(:user) },
      include: [:assignee] }
  }
  
  subject { described_class.new(assignment, default_options).as_json }


  it "should serialize properly" do
    expect(json_document['data']).to have_relationships(:assignee)
    expect(json_document['data']).to have_jsonapi_attributes(:assignedAt, :completedAt)
  end
end
