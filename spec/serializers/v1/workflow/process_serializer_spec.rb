
require 'rails_helper'

describe V1::Workflow::ProcessSerializer do
  let(:process) { build(:workflow_instance_process, steps_count: 1) }

  subject { described_class.new(process).as_json }

  it "should serialize properly" do
    expect(json_document['data']).to have_jsonapi_attributes(:title, :position, :stepsCount, :completedStepsCount, :description, :phase, :status, :categories, :stepsAssignedCount)
    expect(json_document['data']).to have_relationships(:steps, :workflow)
  end
end
