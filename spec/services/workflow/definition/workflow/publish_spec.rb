require 'rails_helper'

RSpec.describe Workflow::Definition::Workflow::Publish do
  let(:previous_version_workflow) { create(:workflow_definition_workflow, published_at: DateTime.now)}
  let(:workflow) { create(:workflow_definition_workflow, previous_version_id: previous_version_workflow.id)}
  let!(:workflow_instance) { create(:workflow_instance_workflow, definition_id: previous_version_workflow.id)}
  let!(:process_instance) { create(:workflow_instance_process, workflow_id: workflow_instance.id, position: 100)}
  let(:subject) { Workflow::Definition::Workflow::Publish.new(workflow.id)}

  describe '#rollout_adds' do
    let(:process_definition) { create(:workflow_definition_process)}

    context 'when it is being added to the front of the list' do
      let!(:selected_process) { create(:selected_process, workflow_id: workflow.id, process_id: process_definition.id, position: 1, state: "added")}

      it 'adds a new process to the workflow instance' do
        expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(1)
        process_instance = process_definition.instances.last
        expect(process_instance.prerequisites_met?).to be_truthy
      end

      context 'when the new process has a prerequisite' do
        let!(:workable_dependency) { create(:workflow_definition_dependency, workflow: workflow, workable: process_definition, prerequisite_workable: process_instance.definition)}

        it 'adds a new process and workable dependency to the workflow instance' do
          expect{ subject.run }.to change{ workflow_instance.reload.dependencies.count}.by(1)
          process_instance = process_definition.instances.last
          expect(process_instance.prerequisites_met?).to be_falsey
        end
      end
    end

    context 'when the previous process by position has been started' do
      let!(:process_instance) { create(:workflow_instance_process, workflow_id: workflow_instance.id, position: 100, completion_status: 2)}
      let!(:selected_process) { create(:selected_process, workflow_id: workflow.id, process_id: process_definition.id, position: 200, state: "added")}

      it 'does not add a process to the workflow instance' do
        expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(1)
      end
    end

    context 'when the previous process by position has not been started' do
      let!(:process_instance) { create(:workflow_instance_process, workflow_id: workflow_instance.id, position: 100, completion_status: 0)}
      let!(:selected_process) { create(:selected_process, workflow_id: workflow.id, process_id: process_definition.id, position: 200, state: "added")}

      it 'adds a new process to the workflow instance' do
        expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(1)
      end
    end

    context 'when the previous process by position has been finished' do
      let!(:process_instance) { create(:workflow_instance_process, workflow_id: workflow_instance.id, position: 100, completion_status: 3)}
      let!(:selected_process) { create(:selected_process, workflow_id: workflow.id, process_id: process_definition.id, position: 200, state: "added")}

      it 'does not add a process to the workflow instance' do
        expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(0)
      end
    end
  end

  describe '#rollout_removes' do
    let!(:selected_process) { create(:selected_process, workflow_id: workflow.id, process_id: process_instance.definition_id, position: 100, state: "removed")}

    context "if the process instance's completion status is unstarted" do
      let!(:process_instance) { create(:workflow_instance_process, workflow_id: workflow_instance.id, position: 100, completion_status: 'unstarted')}

      it "deletes the process, steps and dependencies" do
        expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(-1)
      end
    end

    context "if the process instance's completion status is started" do
      let!(:process_instance) { create(:workflow_instance_process, workflow_id: workflow_instance.id, position: 100, completion_status: 'started')}

      it "skips over the deletion" do
        expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(0)
      end
    end

    context "if the process instance's completion status is finished" do
      let!(:process_instance) { create(:workflow_instance_process, workflow_id: workflow_instance.id, position: 100, completion_status: 'finished')}

      it "skips over the deletion" do
        expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(0)
      end
    end
  end

  describe "#rollout_upgrades" do
    let(:process_definition) { create(:workflow_definition_process)}
    let(:previous_sp) { create(:selected_process, workflow_id: previous_version_workflow.id, process_id: process_instance.definition.id, position: 100) }
    let!(:selected_process) { create(:selected_process, workflow_id: workflow.id, process_id: process_definition.id, position: 100, state: "upgraded", previous_version_id: previous_sp.id)}

    context "if the process instance is unstarted" do
      let!(:process_instance) { create(:workflow_instance_process, workflow_id: workflow_instance.id, position: 100, completion_status: 'unstarted')}

      it "replaces with a new process in the same position" do
        expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(0)
        expect(workflow_instance.processes.where(definition_id: process_definition.id).count).to be(1)
      end

      context 'when the new process has a prerequisite' do
        let!(:process_instance_prerequisite) { create(:workflow_instance_process, workflow_id: workflow_instance.id, position: 50, completion_status: 'unstarted')}
        let!(:workable_dependency) { create(:workflow_definition_dependency, workflow: workflow, workable: process_definition, prerequisite_workable: process_instance_prerequisite.definition)}

        it 'adds a new process and workable dependency to the workflow instance' do
          expect{ subject.run }.to change{ workflow_instance.reload.dependencies.count}.by(1)
          process_instance = process_definition.instances.last
          expect(process_instance.prerequisites_met?).to be_falsey
        end
      end
    end

    context "if the process instance is started" do
      let!(:process_instance) { create(:workflow_instance_process, workflow_id: workflow_instance.id, position: 100, completion_status: 'started')}

      it "does nothing" do
        expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(0)
        expect(workflow_instance.processes.where(definition_id: process_definition.id).count).to be(0)
      end
    end

    context "if the process instance is finished" do
      let!(:process_instance) { create(:workflow_instance_process, workflow_id: workflow_instance.id, position: 100, completion_status: 'finished')}

      it "does nothing" do
        expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(0)
        expect(workflow_instance.processes.where(definition_id: process_definition.id).count).to be(0)
      end
    end
  end
end