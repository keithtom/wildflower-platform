# frozen_string_literal: true

require 'rails_helper'

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
        p definition_workflow.dependencies
        p instance_workflow.dependencies
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
end
