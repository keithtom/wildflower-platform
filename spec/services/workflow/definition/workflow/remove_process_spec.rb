require 'rails_helper'

RSpec.describe Workflow::Definition::Workflow::RemoveProcess do
  describe '#run' do
    let(:workflow) { create(:workflow_definition_workflow) }
    let(:process) { create(:workflow_definition_process) }
    let!(:selected_process) { create(:selected_process, workflow:, process:) }
    let(:subject) { Workflow::Definition::Workflow::RemoveProcess.new(workflow, process) }

    context 'workflow is published' do
      let(:workflow) { create(:workflow_definition_workflow, published_at: DateTime.now) }

      it 'raises an error' do
        expect { subject.run }.to raise_error(Workflow::Definition::Workflow::RemoveProcessError)
      end
    end

    context 'process is a prerequisite of another process' do
      let!(:workable_dependency) do
        Workflow::Definition::Dependency.create(workflow:, prerequisite_workable: process, workable: workable_process)
      end
      let(:workable_process) { create(:workflow_definition_process) }

      it 'raises an error' do
        expect { subject.run }.to raise_error(Workflow::Definition::Workflow::RemoveProcessError)
      end
    end

    context 'selected process associating process is in state: replicated' do
      let!(:selected_process) { create(:selected_process, workflow:, process:, state: 'replicated') }

      it 'updates selected process state to: removed' do
        subject.run
        expect(selected_process.reload.removed?).to be true
      end
    end

    context 'selected process associating process is in state: initialized' do
      let!(:selected_process) { create(:selected_process, workflow:, process:, state: 'initialized') }

      it 'deletes the process and selected process' do
        expect { subject.run }.to change { Workflow::Definition::SelectedProcess.count }.by(-1).and change {
                                                                                                      Workflow::Definition::Process.count
                                                                                                    }.by(-1)
      end
    end

    context 'selected process associating process is in state: added' do
      let!(:selected_process) { create(:selected_process, workflow:, process:, state: 'added') }

      it 'deletes the process and selected process' do
        expect { subject.run }.to change { Workflow::Definition::SelectedProcess.count }.by(-1).and change {
                                                                                                      Workflow::Definition::Process.count
                                                                                                    }.by(-1)
      end

      context 'process was published' do
        let(:process) { create(:workflow_definition_process, published_at: DateTime.now) }

        it 'only deletes the selected process' do
          expect { subject.run }.to change { Workflow::Definition::SelectedProcess.count }.by(-1).and change {
                                                                                                        Workflow::Definition::Process.count
                                                                                                      }.by(0)
        end
      end
    end

    context 'selected process associating process is in state: repositioned' do
      let!(:selected_process) { create(:selected_process, workflow:, process:, state: 'repositioned') }

      it 'updates selected process state to: removed' do
        subject.run
        expect(selected_process.reload.removed?).to be true
      end
    end

    context 'selected process associating process is in state: removed' do
      let!(:selected_process) { create(:selected_process, workflow:, process:, state: 'removed') }

      it 'does nothing' do
        expect_any_instance_of(Workflow::Definition::Workflow::RemoveProcess).not_to receive(:destroy_association)
        subject.run
      end
    end

    context 'when selected process\'s associated process is in state: upgraded' do
      let(:previous_version) do
        create(:selected_process, workflow:, process: create(:workflow_definition_process), state: 'initialized')
      end
      let!(:selected_process) do
        create(:selected_process, workflow:, process:, state: 'upgraded', previous_version:)
      end

      it 'reverts selected process before moving it to removed state' do
        expect(Workflow::Definition::SelectedProcess::Revert).to receive(:run).and_call_original
        subject.run
        expect(selected_process.reload.removed?).to be_truthy
      end
    end
  end
end
