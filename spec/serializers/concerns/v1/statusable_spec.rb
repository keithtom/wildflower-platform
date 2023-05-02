require 'rails_helper'

class StatusableFakeSerializer
  include V1::Statusable
end

RSpec.describe V1::Statusable, type: :concern do
  let(:workflow_definition) { create(:workflow_definition_workflow) }
  let(:workflow) { Workflow::Instance::Workflow.create!(definition: workflow_definition) }
  let(:process_definition) { Workflow::Definition::Process.create!(title: "file taxes", description: "pay taxes to the IRS") }
  let(:process) { Workflow::Instance::Process.create!(definition: process_definition, workflow: workflow) }

  let(:prerequisite_definition) { Workflow::Definition::Process.create!(title: "prepare taxes", description: "gather tax worksheets") }
  let(:prerequisite) { Workflow::Instance::Process.create!(definition: prerequisite_definition, workflow: workflow) }
  let(:dependency_definition) { Workflow::Definition::Dependency.create!(workflow: workflow_definition, workable: process_definition, prerequisite_workable: prerequisite_definition) }
  let!(:dependency) { Workflow::Instance::Dependency.create!(workflow: workflow, workable: process, prerequisite_workable: prerequisite, definition: dependency_definition) }

  let(:person) { create(:person) }

  before do
    3.times do
      process.steps.create! completed: false
    end
  end

  context "process unstarted" do
    before { process.unstarted! }
    
    context "prerequisites unmet" do
      before { process.dependencies_unmet! }
  
      it "has 'up next' status" do
        expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::UP_NEXT)
      end
    end

    context "all prerequisites met" do
      before { process.dependencies_met! }

      it "has 'to do' status" do
        expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::TO_DO)
      end
    end
  end

  context "process started" do
    before do
      process.started!
      process.steps.create!
    end

    it "has 'to do' status" do
      expect(StatusableFakeSerializer.process_status(process.reload)).to eq(V1::Statusable::TO_DO)
    end
  
    context "has incomplete steps that are assigned" do
      before do
        # assign incomplete step
        step = process.steps.incomplete.first
        step.assignments.create!(assignee_id: person.id)
      end

      it "has 'in progress' status" do
        expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::IN_PROGRESS)
      end
    end    
  end

  context "process finished" do
    before { process.finished! }

    it "has 'done' status" do
      expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::DONE)
    end
  end
end
