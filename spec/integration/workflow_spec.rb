# frozen_string_literal: true

require 'rails_helper'

class StatusableFakeSerializer
  include V1::Statusable
end


RSpec.describe "Workflow Feature" do

  context "Given a workflow definition" do
    let(:definition_workflow) { Workflow::Definition::Workflow.create!(version: "v1", name: "Test Workflow", description: "A workflow definition for testing.") }

    let(:definition_process1) { definition_workflow.processes.create!(version: "v1", title: "Process A", description: "An example process that is a pre-requisite to process 2.")  }
    let(:definition_process2) { definition_workflow.processes.create!(version: "v1", title: "Process A", description: "An example process that is a post-requisite to process 1.")  }

    before do
      definition_workflow.dependencies.create!(workable: definition_process2, prerequisite_workable: definition_process1)
    end

    # test multiple workflows?
    it "should have basic associations"

    context "its workflow instance" do
      let(:instance_workflow) { SSJ::Initialize.run(definition_workflow) }
      let(:instance_process1) { definition_process1.instances.first }
      let(:instance_process2) { definition_process2.instances.first }

      it "should have basic associations" do
        expect(instance_workflow.definition).to eq(definition_workflow)
        expect(instance_process1.prerequisites).to be_blank
        expect(instance_process1.postrequisites).to eq([instance_process2])
        expect(instance_process2.prerequisites).to eq([instance_process1])
        expect(instance_process2.postrequisites).to be_blank
      end
    end
  end
  # 1 process unlocks 2
  # 2 processes unlock 1

  context "Given a workflow instance" do
    let!(:process_definition) { create(:workflow_definition_process) }
    before do
      process_definition.steps.create!(kind: Workflow::Definition::Step::DEFAULT, completion_type: Workflow::Definition::Step::EACH_PERSON, position: 1)
      process_definition.steps.create!(kind: Workflow::Definition::Step::DEFAULT, completion_type: Workflow::Definition::Step::ONE_PER_GROUP, position: 1)
      process_definition.steps.create!(kind: Workflow::Definition::Step::DECISION, completion_type: Workflow::Definition::Step::ONE_PER_GROUP, position: 1)
    end

    let!(:prerequisite_definition) { create(:workflow_definition_process) }
    before do
      create(:workflow_definition_step, process: prerequisite_definition)
    end

    let!(:workflow_definition) { create(:workflow_definition_workflow) }
    before do
      workflow_definition.processes << process_definition
      workflow_definition.processes << prerequisite_definition
      workflow_definition.dependencies.create!(workable: process_definition, prerequisite_workable: prerequisite_definition)
    end

    let(:workflow) { SSJ::Initialize.run(workflow_definition) }

    let(:person1) { create(:person) }
    let(:person2) { create(:person) }

    it "complete in order successfully" do
      process = workflow.processes.first
      prerequisite = workflow.processes.last

      expect(process.unstarted?).to be_truthy
      expect(process.prerequisites_met?).to be_falsey
      expect(process.prerequisites.count).to_not eq(0)
      expect(process.steps_count).to eq(3)

      expect(prerequisite.unstarted?).to be_truthy
      expect(prerequisite.prerequisites_met?).to be_truthy
      expect(prerequisite.prerequisites.count).to eq(0)
      expect(prerequisite.steps_count).to eq(1)

      process.steps.each do |step|
        expect(step.completed).to be_falsey
        expect(step.assignments.count).to eq(0)
      end

      expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::UP_NEXT)
      expect(StatusableFakeSerializer.process_status(prerequisite)).to eq(V1::Statusable::TO_DO)

      Workflow::Instance::Step::AssignPerson.run(prerequisite.steps.first, person1)

      expect(prerequisite.started?).to be_truthy
      expect(StatusableFakeSerializer.process_status(prerequisite)).to eq(V1::Statusable::IN_PROGRESS)
      
      Workflow::Instance::Step::Complete.run(prerequisite.steps.first, person1)

      expect(prerequisite.finished?).to be_truthy
      expect(prerequisite.completed_at).to_not be_blank
      expect(StatusableFakeSerializer.process_status(prerequisite)).to eq(V1::Statusable::DONE)
      
      process.reload
      expect(process.prerequisites_met?).to be_truthy
      expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::TO_DO)

      step = process.steps.first
      Workflow::Instance::Step::AssignPerson.run(step, person1)

      expect(process.started?).to be_truthy
      expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::IN_PROGRESS)

      Workflow::Instance::Step::Complete.run(step, person1)

      expect(process.completed_steps_count).to eq(1)
      expect(process.started?).to be_truthy
      expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::TO_DO)

      Workflow::Instance::Step::Uncomplete.run(step, person1)
      expect(process.completed_steps_count).to eq(0)
      expect(process.started?).to be_truthy
      expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::IN_PROGRESS)

      Workflow::Instance::Step::UnassignPerson.run(step, person1)
      expect(process.unstarted?).to be_truthy
      expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::TO_DO)

      process.steps.each do |step|
        Workflow::Instance::Step::Complete.run(step, person1)
      end

      expect(process.finished?).to be_truthy
      expect(process.completed_steps_count).to eq(3)
      expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::DONE)

      # TODO
      # test change of phase
      # and the last phase all done, will it transitin properly to where?
    end

    it "complete out of order successfully" do
      process = workflow.processes.first
      prerequisite = workflow.processes.last

      expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::UP_NEXT)

      step = process.steps.first
      Workflow::Instance::Step::AssignPerson.run(step, person1)

      expect(process.started?).to be_truthy
      expect(process.prerequisites_met?).to be_falsey
      expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::IN_PROGRESS)

      Workflow::Instance::Step::UnassignPerson.run(step, person1)

      expect(process.unstarted?).to be_truthy
      expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::UP_NEXT)

      Workflow::Instance::Step::Complete.run(step, person1)
      expect(process.started?).to be_truthy
      expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::TO_DO)

      step2 = process.steps.last
      Workflow::Instance::Step::AssignPerson.run(step2, person1)

      expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::IN_PROGRESS)

      process.steps.each do |step|
        Workflow::Instance::Step::Complete.run(step, person1)
      end

      expect(process.finished?).to be_truthy
      expect(process.completed_steps_count).to eq(3)
      expect(StatusableFakeSerializer.process_status(process)).to eq(V1::Statusable::DONE)
    end

    # test multiple completesr?
    # that if we have collaborative steps, it unlocks for everyone.
    # if we have individual steps, it still unlocks.
    # assign/unassign, compelte/uncomplete steps
    #   decision steps
    #   individual/collaborative steps
    
    # uncomplete spec.  test that if one person completes a collaborative, other can't complete or uncomplete it.  maybe we should let you still complete?
  end
end

# complete process not yet dependencies met, what about down stream postrequisites, they unlock?
# create manual steps
# create manual processes
# complete a phase