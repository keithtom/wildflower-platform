
require 'rails_helper'

describe V1::Workflow::StepSerializer do
  let(:assignee) { create(:person) }
  let(:step) { build(:workflow_instance_step, assignee_id: assignee.id) }

  subject { described_class.new(step).as_json }

  before do
    3.times do |i|
      step.definition.decision_options.new(description: "option #{i}")
    end
  end

  it "should serialize properly" do
    expect(json_document['data']).to have_relationships(:process, :documents)
    expect(json_document['data']).to have_jsonapi_attributes(:completed, :completedAt, :decisionOptions, :kind, :position, :title, :min_worktime, :max_worktime)
    expect(json_document['data']). to have_jsonapi_attributes(:assigneeInfo)
  end
end
