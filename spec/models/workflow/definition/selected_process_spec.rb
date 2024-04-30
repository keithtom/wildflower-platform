require 'rails_helper'

RSpec.describe Workflow::Definition::SelectedProcess, type: :model do
  describe "#revert" do
    let(:previous_version) { create(:selected_process, position: 100) }

    context "when the selected process is upgraded" do
      let(:selected_process) { create(:selected_process, previous_version: previous_version) }

      before do
        selected_process.replicate!
        selected_process.upgrade!
      end

      it "destroys the current process and assigns the previous version's process to it" do
        expect { selected_process.revert! }.to change { Workflow::Definition::Process.count }.by(-1)
        expect(selected_process.process).to eq(previous_version.process)
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
        expect { selected_process.revert! }.to change { Workflow::Definition::Process.count }.by(0)
        expect(selected_process.process).to eq(previous_version.process)
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
        expect { selected_process.revert! }.to change { Workflow::Definition::Process.count }.by(0)
        expect(selected_process.process).to eq(previous_version.process)
        expect(selected_process.replicated?).to be true
        expect(selected_process.position).to eq(previous_version.position)
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