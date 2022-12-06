
require 'rails_helper'

describe V1::Workflow::StepSerializer do
  let(:step) { build(:workflow_instance_step) }

  subject { described_class.new(step).as_json }

  before do
    3.times do |i|
      step.definition.decision_options.new(description: "option #{i}")
    end
  end

  it "should serialize properly" do
    puts json_document.inspect
    expect(json_document['data']).to have_relationships(:process, :documents)
    expect(json_document['data']).to have_jsonapi_attributes(:completed, :completedAt, :decisionOptions, :kind, :position, :title)
  end
end
