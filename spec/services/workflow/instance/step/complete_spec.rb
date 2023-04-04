require "rails_helper"

describe Workflow::Instance::Step::Complete do
  let(:person) { create(:person) }
  let(:person2) { create(:person) }
  let(:step) { create(:workflow_instance_step) }

  it "completes by multiple people" do
    expect(step).to_not be_completed

    described_class.run(step, person)

    expect(step).to be_completed
    expect(step.assignments.count).to eq(1)
    expect(step.assignments).to include(
      have_attributes(assignee: person, completed_at: any)
    )

    described_class.run(step, person2)
    
    expect(step.assignments.count).to eq(2)
    expect(step.assignments).to include(
      have_attributes(assignee: person, completed_at: any)
    )
    expect(step.assignments).to include(
      have_attributes(assignee: person2, completed_at: any)
    )
  end

  it "is idempotent" do
    described_class.run(step, person)
    assignment = step.assignments.first
    completed_time = assignment.completed_at

    described_class.run(step, person)
    expect(step).to be_completed
    expect(step.assignments.count).to eq(1)
    expect(assignment.reload.completed_at).to eq(completed_time)

    # should not notify or update the process
  end

  it "updates the process" do
    # check computer cache and status.
  end
end