require 'rails_helper'

describe Workflow::Instance::Step::UnassignPerson do
  let(:person) { create(:person) }
  let(:person2) { create(:person) }
  let(:step) { create(:workflow_instance_step) }
  let(:ssj_team) { create(:ssj_team, workflow_id: step.process.workflow_id) }
  let!(:ssj_team_member) { create(:ssj_team_member, ssj_team:, person:) }
  let!(:ssj_team_member!) { create(:ssj_team_member, ssj_team:, person: person2) }

  context 'when there are assigned people' do
    before do
      Workflow::Instance::Step::AssignPerson.run(step, person)
      Workflow::Instance::Step::AssignPerson.run(step, person2)
    end

    it 'unassigns a person from a step' do
      expect(step.assignments.count).to eq(2)
      expect(step.assignments).to include(
        have_attributes(assignee: person)
      )
      expect(step.assignments).to include(
        have_attributes(assignee: person2)
      )

      described_class.run(step, person, person)
      expect(step.assignments.count).to eq(1)
      expect(step.assignments).to include(
        have_attributes(assignee: person2)
      )

      described_class.run(step, person2, person2)
      expect(step.assignments.count).to eq(0)
    end

    it 'is idempotent' do
      expect(step.assignments.count).to eq(2)

      described_class.run(step, person, person)
      described_class.run(step, person, person)

      expect(step.assignments.count).to eq(1)
    end
  end

  context 'when person unassigning is not part of the group' do
    let(:person3) { create(:person) }

    it 'raises an error' do
      expect do
        described_class.run(step, person, person3)
      end.to raise_error(Workflow::Instance::Step::UnassignPersonError)
    end
  end

  it "works even if person isn't assigned" do
    expect { described_class.run(step, person, person) }.not_to raise_error
    expect(step.assignments.count).to eq(0)
  end
end
