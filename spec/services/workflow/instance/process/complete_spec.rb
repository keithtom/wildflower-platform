require "rails_helper"

describe Workflow::Instance::Process::Complete do
  let(:process) { create(:workflow_instance_process) }
    
  subject! { described_class.run(process) }

  it "should complete the process" do
    expect(process.reload.completed_at).to_not be_nil
    expect(process).to be_finished
  end

  context do
    let(:workflow) { create(:workflow_instance_workflow) }
    let!(:visioning_process) { create(:workflow_instance_process, workflow: workflow, phase_list: [SSJ::Phase::VISIONING]) }
    let!(:planning_process) { create(:workflow_instance_process, workflow: workflow, phase_list: [SSJ::Phase::PLANNING]) }
    let!(:startup_process) { create(:workflow_instance_process, workflow: workflow, phase_list: [SSJ::Phase::STARTUP]) }
    let!(:open_process) { create(:workflow_instance_process, workflow: workflow, phase_list: [SSJ::Phase::OPEN]) }

    before do
      expect(workflow.processes.tagged_with(SSJ::Phase::VISIONING, on: :phase, any: true).count).to eq(1)
      expect(workflow.processes.tagged_with(SSJ::Phase::PLANNING, on: :phase, any: true).count).to eq(1)
      expect(workflow.processes.tagged_with(SSJ::Phase::STARTUP, on: :phase, any: true).count).to eq(1)
    end

    it "should update the current phase" do
      expect(workflow.current_phase).to eq(SSJ::Phase::VISIONING)
      
      described_class.run(visioning_process)
      expect(workflow.current_phase).to eq(SSJ::Phase::PLANNING)

      described_class.run(planning_process)
      expect(workflow.current_phase).to eq(SSJ::Phase::STARTUP)

      described_class.run(startup_process)
      expect(workflow.current_phase).to eq(SSJ::Phase::OPEN)

      described_class.run(open_process)
      expect(workflow.current_phase).to eq(SSJ::Phase::OPEN)
    end
  end

  context do
    let(:workflow) { create(:workflow_instance_workflow) }
    let!(:process) { create(:workflow_instance_process, workflow: workflow, phase_list: [SSJ::Phase::VISIONING]) }
  
    let!(:prerequisite1) { create(:workflow_instance_process, workflow: workflow, phase_list: [SSJ::Phase::VISIONING]) }
    let!(:prerequisite2) { create(:workflow_instance_process, workflow: workflow, phase_list: [SSJ::Phase::VISIONING]) }
    let!(:dependency1) { create(:workflow_instance_dependency, workflow: workflow, workable: process, prerequisite_workable: prerequisite1) }
    let!(:dependency2) { create(:workflow_instance_dependency, workflow: workflow, workable: process, prerequisite_workable: prerequisite2) }
  
    it "should update postrequisites whose prerequisites are all complete" do
      expect(process).to_not be_prerequisites_met

      described_class.run(prerequisite1)
      process.reload
      expect(process).to_not be_prerequisites_met

      described_class.run(prerequisite2)
      process.reload
      expect(process).to be_prerequisites_met
    end
  end
end