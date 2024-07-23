require "rails_helper"

describe Workflow::Instance::Step::AssignPerson do
  let(:person) { create(:person) }
  let(:person2) { create(:person) }
  let(:step) { create(:workflow_instance_step) }

  context 'when valid' do
    let(:ssj_team) { create(:ssj_team, workflow_id: step.process.workflow_id) }
    let!(:ssj_team_member) { create(:ssj_team_member, ssj_team: ssj_team, person: person)}
    let!(:ssj_team_member!) { create(:ssj_team_member, ssj_team: ssj_team, person: person2)}

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

  context 'when assigning a person to a step from a workflow that the person does not belong to' do
    it 'raises an error' do
      expect{described_class.run(step, person)}.to raise_error
    end
  end
end