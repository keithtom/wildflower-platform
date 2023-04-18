
require 'rails_helper'

describe V1::Workflow::StepSerializer do
  let(:step) { create(:workflow_instance_step) }
  let!(:assignee) { create(:workflow_instance_step_assignment, step: step).assignee }

  let(:default_options) {
    { include: [:process, :documents, :assignments] }
  }
  
  subject { described_class.new(step, default_options).as_json }

  before do
    3.times do |i|
      step.definition.decision_options.new(description: "option #{i}")
    end
  end

  it "should serialize properly" do
    expect(json_document['data']).to have_relationships(:process, :documents, :assignments)
    expect(json_document['data']).to have_jsonapi_attributes(:completed, :decisionOptions, :kind, :position, :title, :minWorktime, :maxWorktime)
  end
end
