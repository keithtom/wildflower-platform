require 'rails_helper'

describe Workflow::Instance::Step::Complete do
  let(:person) { create(:person) }
  let(:person2) { create(:person) }
  let(:step) { create(:workflow_instance_step) }

  it 'completes by multiple people' do
    expect(step).not_to be_completed

    described_class.run(step, person)

    expect(step).to be_completed
    expect(step.assignments.count).to eq(1)
    expect(step.assignments).to include(
      have_attributes(assignee: person, completed_at: kind_of(Time))
    )

    described_class.run(step, person2)

    expect(step.assignments.count).to eq(2)
    expect(step.assignments).to include(
      have_attributes(assignee: person, completed_at: kind_of(Time))
    )
    expect(step.assignments).to include(
      have_attributes(assignee: person2, completed_at: kind_of(Time))
    )
  end

  it 'is idempotent' do
    described_class.run(step, person)
    assignment = step.assignments.first
    completed_time = assignment.completed_at

    described_class.run(step, person)
    expect(step).to be_completed
    expect(step.assignments.count).to eq(1)
    expect(assignment.reload.completed_at).to eq(completed_time)

    # should not notify or update the process
  end

  it 'updates the process' do
    # check computer cache and status.
  end

  context 'when step is collaborative and assigned to 2 people' do
    let(:step) { create(:workflow_instance_step, completion_type: Workflow::Definition::Step::ONE_PER_GROUP) }

    before do
      step.assignments.find_or_create_by!(assignee: person)
      step.assignments.find_or_create_by!(assignee: person2)
      step.assigned = true
      step.save!
    end

    it 'completes and removes other assignees' do
      expect(step.assignments.count).to eq(2)
      described_class.run(step, person)
      expect(step).to be_completed
      expect(step.assignments.count).to eq(1)
      expect(step.assignments).to include(
        have_attributes(assignee: person, completed_at: kind_of(Time))
      )
    end
  end

  context 'when step is a decision type and assigned to 2 people' do
    let(:step) { create(:workflow_instance_step, kind: Workflow::Definition::Step::DECISION) }

    before do
      step.assignments.find_or_create_by!(assignee: person)
      step.assignments.find_or_create_by!(assignee: person2)
      step.assigned = true
      step.save!
    end

    it 'completes and removes other assignees' do
      expect(step.assignments.count).to eq(2)
      described_class.run(step, person)
      expect(step).to be_completed
      expect(step.assignments.count).to eq(1)
      expect(step.assignments).to include(
        have_attributes(assignee: person, completed_at: kind_of(Time))
      )
    end
  end
end
