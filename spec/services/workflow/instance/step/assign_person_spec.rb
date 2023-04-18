require "rails_helper"

describe Workflow::Instance::Step::AssignPerson do
  let(:person) { create(:person) }
  let(:person2) { create(:person) }
  let(:step) { create(:workflow_instance_step) }

  it "assigns multiple people to a step" do
    expect(step.assignments.count).to eq(0)

    described_class.run(step, person)

    expect(step.assignments.count).to eq(1)
    expect(step.assignments).to include(
      have_attributes(assignee: person)
    )

    described_class.run(step, person2)
    
    expect(step.assignments.count).to eq(2)
    expect(step.assignments).to include(
      have_attributes(assignee: person)
    )
    expect(step.assignments).to include(
      have_attributes(assignee: person2)
    )

  end

  it "is idempotent" do
    described_class.run(step, person)
    described_class.run(step, person)

    expect(step.assignments.count).to eq(1)
  end
end