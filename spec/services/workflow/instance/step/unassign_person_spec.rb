require "rails_helper"

describe Workflow::Instance::Step::UnassignPerson do
  let(:person) { create(:person) }
  let(:person2) { create(:person) }
  let(:step) { create(:workflow_instance_step) }

  context "when there are assigned people" do
    before do
      Workflow::Instance::Step::AssignPerson.run(step, person)
      Workflow::Instance::Step::AssignPerson.run(step, person2)
    end

    it "unassigns a person from a step" do
      expect(step.assignments.count).to eq(2)
      expect(step.assignments).to include(
        have_attributes(assignee: person)
      )
      expect(step.assignments).to include(
        have_attributes(assignee: person2)
      )

      described_class.run(step, person)
      expect(step.assignments.count).to eq(1)
      expect(step.assignments).to include(
        have_attributes(assignee: person2)
      )

      described_class.run(step, person2)
      expect(step.assignments.count).to eq(0)
    end

    it "is idempotent" do
      expect(step.assignments.count).to eq(2)

      described_class.run(step, person)
      described_class.run(step, person)

      expect(step.assignments.count).to eq(1)
    end
  end

  it "works even if person isn't assigned" do
    expect { described_class.run(step, person) }.not_to raise_error
    expect(step.assignments.count).to eq(0)
  end
end
