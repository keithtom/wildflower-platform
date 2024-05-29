require 'rails_helper'

RSpec.describe Workflow::Definition::SelectedProcess::Revert do
  describe '#run' do
    let(:previous_version) { create(:selected_process, position: 100) }
    let(:subject) { Workflow::Definition::SelectedProcess::Revert.new(selected_process) }

    context 'when selected process does not have previous version' do
      let(:selected_process) { create(:selected_process) }
    
      it 'raises an error' do
        expect{ subject.run }.to raise_error(Workflow::Definition::SelectedProcess::RevertError)
      end
    end

    context "when the selected process is upgraded" do
      let(:selected_process) { create(:selected_process, previous_version: previous_version) }

      before do
        selected_process.replicate!
        selected_process.upgrade!
      end

      it "destroys the current process and assigns the previous version's process to it" do
        expect { subject.run }.to change { Workflow::Definition::Process.count }.by(-1)
        expect(selected_process.process).to eq(previous_version.process)
        expect(selected_process.position).to eq(previous_version.position)
        expect(selected_process.replicated?).to be true
      end
    end

    context "when selected process is removed" do
      let(:selected_process) { create(:selected_process, process: previous_version.process, previous_version: previous_version) }

      before do
        selected_process.replicate!
        selected_process.remove!
      end

      it "sets state back to replicated, and doesn't delete the process" do
        expect { subject.run }.to change { Workflow::Definition::Process.count }.by(0)
        expect(selected_process.process).to eq(previous_version.process)
        expect(selected_process.position).to eq(previous_version.position)
        expect(selected_process.replicated?).to be true
      end
    end

    context "when selected process is repositioned" do
      let(:selected_process) { create(:selected_process, process: previous_version.process, previous_version: previous_version, position: 200) }

      before do
        selected_process.replicate!
        selected_process.reposition!
      end

      it "sets state back to replicated, and reverts position" do
        expect { subject.run }.to change { Workflow::Definition::Process.count }.by(0)
        expect(selected_process.process).to eq(previous_version.process)
        expect(selected_process.position).to eq(previous_version.position)
        expect(selected_process.replicated?).to be true
      end
    end
    
    context 'when process is a prerequisite' do
      let(:selected_process) { create(:selected_process, previous_version: previous_version) }
      let!(:dependency) { create(:workflow_definition_dependency, workflow_id: selected_process.workflow_id, prerequisite_workable: selected_process.process) }

      before do
        selected_process.replicate!
        selected_process.upgrade!
      end

      it 'updates the prerequisite to the previous process' do
        expect { subject.run }.to change { Workflow::Definition::Process.count }.by(-1)
        expect(dependency.reload.prerequisite_workable).to eq(previous_version.process)
      end
    end

    context 'when process has a prerequisite' do
      let(:selected_process) { create(:selected_process, previous_version: previous_version) }
      let!(:dependency) { create(:workflow_definition_dependency, workflow_id: selected_process.workflow_id, workable: selected_process.process) }

      before do
        selected_process.replicate!
        selected_process.upgrade!
      end

      it 'updates the dependent process to the previous process' do
        expect { subject.run }.to change { Workflow::Definition::Process.count }.by(-1)
        expect(dependency.reload.workable).to eq(previous_version.process)
      end
    end

    # context "when the process is not upgraded" do
    #   it "does not destroy the current process and keeps the same process" do
    #     expect { selected_process.revert_to_previous_version }.not_to change { Workflow::Definition::SelectedProcess.count }
    #     expect(selected_process.process).to eq(selected_process.previous_version.process)
    #   end
    # end
  end
end