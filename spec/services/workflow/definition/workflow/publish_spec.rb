require 'rails_helper'

RSpec.describe Workflow::Definition::Workflow::Publish do
  let(:previous_version_workflow) { create(:workflow_definition_workflow, published_at: DateTime.now)}
  let(:workflow) { create(:workflow_definition_workflow, previous_version_id: previous_version_workflow.id)}
  let!(:workflow_instance) { create(:workflow_instance_workflow, definition_id: previous_version_workflow.id)}
  let!(:process_instance) { create(:workflow_instance_process, workflow_id: workflow_instance.id, position: 100)}
  let(:subject) { Workflow::Definition::Workflow::Publish.new(workflow.id)}
  let(:previous_sp) { create(:selected_process, workflow_id: previous_version_workflow.id, process_id: process_instance.definition.id, position: 100) }

  describe '#rollout_adds' do
    context 'with non recurring workflow/process' do
      let(:process_definition) { create(:workflow_definition_process)}

      context 'when it is being added to the front of the list' do
        let!(:selected_process) { create(:selected_process, workflow_id: workflow.id, process_id: process_definition.id, position: 1, state: "added")}

        it 'adds a new process to the workflow instance' do
          expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(1)
          process_instance = process_definition.instances.last
          expect(process_instance.prerequisites_met?).to be_truthy
          expect(process_definition.reload.published_at).to_not be_nil
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

    context 'with recurring workflow/process' do
      let(:process_definition) { create(:workflow_definition_process, recurring: true, due_months: [1], duration: 1)}
      let!(:selected_process) { create(:selected_process, workflow_id: workflow.id, process_id: process_definition.id, state: "added")}
      let(:previous_version_workflow) { create(:workflow_definition_workflow, published_at: DateTime.now, recurring: true)}
      let(:workflow) { create(:workflow_definition_workflow, previous_version_id: previous_version_workflow.id, recurring: true)}

      context 'when due date is today' do
        before do
          allow_any_instance_of(OpenSchools::DateCalculator).to receive(:due_date).and_return(Date.today)
        end

        it 'does not add a process to the workflow instance' do
          expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(0)
        end
      end

      context 'when due date is yesterday' do
        before do
          allow_any_instance_of(OpenSchools::DateCalculator).to receive(:due_date).and_return(Date.today - 1.day)
        end

        it 'does not add a process to the workflow instance' do
          expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(0)
        end
      end

      context 'when due date is tomorrow' do
        before do
          allow_any_instance_of(OpenSchools::DateCalculator).to receive(:due_date).and_return(Date.today + 1.day)
        end

        it 'does add a process to the workflow instance' do
          expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(1)
        end
      end
    end
  end

  describe '#rollout_removes' do
    let!(:selected_process) { create(:selected_process, workflow_id: workflow.id, process_id: process_instance.definition_id, position: 100, state: "removed", previous_version_id: previous_sp.id)}

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

  describe '#rollout_upgrades' do
    context 'with non recurring workflow/process' do
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

      context 'when the process instance is started' do
        let!(:process_instance) { create(:workflow_instance_process, workflow_id: workflow_instance.id, position: 100, completion_status: 'started')}

        it "does nothing" do
          expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(0)
          expect(workflow_instance.processes.where(definition_id: process_definition.id).count).to be(0)
        end
      end

      context 'when the process instance is finished' do
        let!(:process_instance) { create(:workflow_instance_process, workflow_id: workflow_instance.id, position: 100, completion_status: 'finished')}

        it "does nothing" do
          expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(0)
          expect(workflow_instance.processes.where(definition_id: process_definition.id).count).to be(0)
        end
      end
    end

    context 'with recurring workflow/process' do
      let(:process_definition) { create(:workflow_definition_process, recurring: true, due_months: [1], duration: 1)}
      let!(:selected_process) { create(:selected_process, workflow_id: workflow.id, process_id: process_definition.id, position: 100, state: "upgraded", previous_version_id: previous_sp.id)}
      let(:previous_sp) { create(:selected_process, workflow_id: previous_version_workflow.id, process_id: process_instance.definition.id, position: 100) }
      let(:previous_version_workflow) { create(:workflow_definition_workflow, published_at: DateTime.now, recurring: true)}
      let(:workflow) { create(:workflow_definition_workflow, previous_version_id: previous_version_workflow.id, recurring: true)}

      context 'when process is started/finished' do
        let(:prev_process_definition) { create(:workflow_definition_process, recurring: true, due_months: [1], duration: 1)}
        let!(:process_instance) { create(:workflow_instance_process, definition_id: prev_process_definition.id, workflow_id: workflow_instance.id, position: 100, completion_status: 'started')}

        context 'when due date is today' do
          before do
            allow_any_instance_of(OpenSchools::DateCalculator).to receive(:due_date).and_return(Date.today)
          end

          it 'does not add a process to the workflow instance' do
            expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(0)
            expect(workflow_instance.processes.where(definition_id: process_definition.id).count).to be(0)
          end
        end

        context 'when due date is yesterday' do
          before do
            allow_any_instance_of(OpenSchools::DateCalculator).to receive(:due_date).and_return(Date.today - 1.day)
          end

          it 'does not add a process to the workflow instance' do
            expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(0)
            expect(workflow_instance.processes.where(definition_id: process_definition.id).count).to be(0)
          end
        end

        context 'when due date is tomorrow' do
          before do
            allow_any_instance_of(OpenSchools::DateCalculator).to receive(:due_date).and_return(Date.today + 1.day)
          end

          it 'does add a process to the workflow instance' do
            expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(0)
            expect(workflow_instance.processes.where(definition_id: process_definition.id).count).to be(0)
          end
        end
      end

      context 'when process is unstarted' do
        let(:prev_process_definition) { create(:workflow_definition_process, recurring: true, due_months: [1], duration: 1)}
        let!(:process_instance) { create(:workflow_instance_process, definition_id: prev_process_definition.id, workflow_id: workflow_instance.id, position: 100, completion_status: 'unstarted')}

        context 'when due date is today' do
          before do
            allow_any_instance_of(OpenSchools::DateCalculator).to receive(:due_date).and_return(Date.today)
          end

          it 'does not add a process to the workflow instance' do
            expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(0)
            expect(workflow_instance.processes.where(definition_id: process_definition.id).count).to be(0)
          end
        end

        context 'when due date is yesterday' do
          before do
            allow_any_instance_of(OpenSchools::DateCalculator).to receive(:due_date).and_return(Date.today - 1.day)
          end

          it 'does not add a process to the workflow instance' do
            expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(0)
            expect(workflow_instance.processes.where(definition_id: process_definition.id).count).to be(0)
          end
        end

        context 'when due date is tomorrow' do
          before do
            allow_any_instance_of(OpenSchools::DateCalculator).to receive(:due_date).and_return(Date.today + 1.day)
          end

          it 'does add a process to the workflow instance' do
            expect{ subject.run }.to change{ workflow_instance.reload.processes.count}.by(0)
            expect(workflow_instance.processes.where(definition_id: process_definition.id).count).to be(1)
          end
        end
      end

      context 'when some of the process instances are unstarted, started and finished' do
        let(:process_definition) { create(:workflow_definition_process, recurring: true, due_months: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], duration: 1)}
        let!(:selected_process) { create(:selected_process, workflow_id: workflow.id, process_id: process_definition.id, position: 100, state: "upgraded", previous_version_id: previous_sp.id)}
        let(:previous_sp) { create(:selected_process, workflow_id: previous_version_workflow.id, process_id: prev_process_def.id, position: 100) }
        let(:prev_process_def) { create(:workflow_definition_process, recurring: true, due_months: [9, 1, 4, 7], duration: 1)}
        let!(:process_instance_1) { create(:workflow_instance_process, definition_id: prev_process_def.id, workflow_id: workflow_instance.id, position: 100, completion_status: 'finished', due_date: Date.new(2024, 9, 30))}
        let!(:process_instance_2) { create(:workflow_instance_process, definition_id: prev_process_def.id, workflow_id: workflow_instance.id, position: 200, completion_status: 'finished', due_date: Date.new(2025, 1, 31))}
        let!(:process_instance_3) { create(:workflow_instance_process, definition_id: prev_process_def.id, workflow_id: workflow_instance.id, position: 300, completion_status: 'unstarted', due_date: Date.new(2025, 4, 30))}
        let!(:process_instance_4) { create(:workflow_instance_process, definition_id: prev_process_def.id, workflow_id: workflow_instance.id, position: 400, completion_status: 'unstarted', due_date: Date.new(2025, 7, 31))}

        before do
          allow_any_instance_of(ActiveSupport::TimeZone).to receive(:today).and_return(Date.new(2025, 3, 15))
        end

        it 'does not remove the started or completed ones, creates the new ones in the future' do
          # 2 are removed, because they are unstated, and 6 are created
          expect { subject.run }. to change { workflow_instance.reload.processes.count}.by(4)
        end
      end

      context 'when all of the process instances are unstarted, some are past due' do
        let(:process_definition) { create(:workflow_definition_process, recurring: true, due_months: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], duration: 1)}
        let!(:selected_process) { create(:selected_process, workflow_id: workflow.id, process_id: process_definition.id, position: 100, state: "upgraded", previous_version_id: previous_sp.id)}
        let(:previous_sp) { create(:selected_process, workflow_id: previous_version_workflow.id, process_id: prev_process_def.id, position: 100) }
        let(:prev_process_def) { create(:workflow_definition_process, recurring: true, due_months: [9, 1, 4, 7], duration: 1)}
        let!(:process_instance_1) { create(:workflow_instance_process, definition_id: prev_process_def.id, workflow_id: workflow_instance.id, position: 100, completion_status: 'unstarted', due_date: Date.new(2024, 9, 30))}
        let!(:process_instance_2) { create(:workflow_instance_process, definition_id: prev_process_def.id, workflow_id: workflow_instance.id, position: 200, completion_status: 'unstarted', due_date: Date.new(2025, 1, 31))}
        let!(:process_instance_3) { create(:workflow_instance_process, definition_id: prev_process_def.id, workflow_id: workflow_instance.id, position: 300, completion_status: 'unstarted', due_date: Date.new(2025, 4, 30))}
        let!(:process_instance_4) { create(:workflow_instance_process, definition_id: prev_process_def.id, workflow_id: workflow_instance.id, position: 400, completion_status: 'unstarted', due_date: Date.new(2025, 7, 31))}

        before do
          allow_any_instance_of(ActiveSupport::TimeZone).to receive(:today).and_return(Date.new(2025, 3, 15))
        end

        it 'does not remove the started or completed ones, creates the new ones in the future' do
          # 4 are removed, because they are unstated, and 6 are created
          expect { subject.run }. to change { workflow_instance.reload.processes.count}.by(2)
        end
      end
    end
  end

  describe "#rollout_repositions" do
    let!(:selected_process) { 
      create(:selected_process, workflow_id: workflow.id, process_id: process_instance.definition_id, position: 200, state: "repositioned", previous_version_id: previous_sp.id)
    }

    it 'updates the position of the process instance' do
      subject.run
      expect(process_instance.reload.position).to eq(200)
    end
  end

  describe 'run' do
    context 'when an error is raised' do
      let(:process_definition) { create(:workflow_definition_process)}

      before do
        create(:selected_process, workflow_id: workflow.id, process_id: process_definition.id, position: 1, state: 'added')
      end

      it 'marks the workflow as needs support' do
        allow(subject).to receive(:rollout_adds).and_raise(RuntimeError, 'Error occurred during rollout_adds')
        subject.run
        expect(workflow.reload.needs_support).to be_truthy
        expect(workflow.published?).to be_falsey
      end
    end
  end
end
