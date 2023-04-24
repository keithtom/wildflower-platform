
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
    expect(json_document['data']).to have_jsonapi_attributes(:kind, :position, :title, :minWorktime, :maxWorktime)
    expect(json_document['data']).not_to have_jsonapi_attributes(:completed) # this is for backend use purposes and means something different in the front-end, it is likely a mistake to send this.  Please read the README.md in the models/workflow folder
  end

  context "when it is a decision step" do
    let(:step) { create(:workflow_instance_step, kind: Workflow::Definition::Step::DECISION) }
   
    it "should serialize properly" do
      expect(json_document['data']).to have_jsonapi_attributes(:decisionOptions)
    end
  end
end
