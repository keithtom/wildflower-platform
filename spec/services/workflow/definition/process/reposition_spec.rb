require 'rails_helper'

RSpec.describe Workflow::Definition::SelectedProcess::Reposition, type: :service do
  let(:workflow) { create(:workflow_definition_workflow) }
  let!(:workflow_instance) { create(:workflow_instance_workflow, definition: workflow) }
  let(:first_position) { 100 }
  let(:sp_first) { create(:selected_process, workflow: workflow, position: first_position) }
  let!(:process_instance_first) { create(:workflow_instance_process, definition: sp_first.process, position: first_position, workflow: workflow_instance) }
  let(:second_position) { 200 }
  let!(:sp_second) { create(:selected_process, workflow: workflow, position: second_position) }
  let!(:process_instance_second) { create(:workflow_instance_process, definition: sp_second.process, position: second_position, workflow: workflow_instance) }
  let(:third_position) { 300 }
  let!(:sp_third) { create(:selected_process, workflow: workflow, position: third_position) }
  let!(:process_instance_third) { create(:workflow_instance_process, definition: sp_third.process, position: third_position, workflow: workflow_instance) }
  let(:position) { 250 }

  subject { described_class.new(sp_first, position) }

  describe "#run" do
    context "position is not an integer" do
      let(:position) { 200.5 }
      
      it "raises an error" do
        expect{subject.run}.to raise_error(Workflow::Definition::SelectedProcess::RepositionError)
      end
    end

    context "position is 0" do
      let(:position) { 0 }
      
      it "raises an error" do
        expect{subject.run}.to raise_error(Workflow::Definition::SelectedProcess::RepositionError)
      end
    end

    context "renumbering is needed" do
      let!(:sp_first) { create(:selected_process, workflow: workflow, position: first_position) }
      let!(:sp_second) { create(:selected_process, workflow: workflow, position: first_position) }

      it "raises an error" do
        expect{subject.run}.to raise_error(Workflow::Definition::SelectedProcess::RepositionError)
      end
    end

    context "when the workflow is published" do
      before do
        allow(workflow).to receive(:published?).and_return(true)
      end

      it "updates the selected process position and propagates the change to instances" do
        subject.run
        expect(sp_first.reload.position).to eq(position)
        expect(process_instance_first.reload.position).to eq(position)
      end
    
      context "renumbering is needed after update of position" do
        let(:first_position) { 100 }
        let(:second_position) { 102 }
        let(:third_position) { 104 }
        let(:position) { 103 }

        it "renumbers the selected processes' positions and the process instances' positions" do
          subject.run
          expect(sp_first.reload.position).to eq(2000)
          expect(sp_second.reload.position).to eq(1000)
          expect(sp_third.reload.position).to eq(3000)
        
          expect(process_instance_first.reload.position).to eq(2000)
          expect(process_instance_second.reload.position).to eq(1000)
          expect(process_instance_third.reload.position).to eq(3000)
        end
      end
    end

    context "when the workflow is not published" do
      before do
        allow(workflow).to receive(:published?).and_return(false)
      end

      context "renumbering is needed after update of position" do
        let(:first_position) { 100 }
        let(:second_position) { 102 }
        let(:third_position) { 104 }
        let(:position) { 103 }

        before do
          sp_first.update(state: 'replicated')
        end

        it "renumbers the selected processes' positions" do
          subject.run
          expect(sp_first.reload.position).to eq(2000)
          expect(sp_second.reload.position).to eq(1000)
          expect(sp_third.reload.position).to eq(3000)
        end
      end

      context 'when selected process is replicated' do
        before do
          sp_first.update(state: 'replicated')
          subject.run
        end

        it 'updates the selected process' do
          expect(sp_first.reload.position).to eq(position)
        end

        it 'repositions the selected process' do
          expect(sp_first.reload.state).to eq('repositioned')
        end
      end

      context 'when selected process is in added state' do
        before do
          sp_first.update(state: 'added')
          subject.run
        end

        it 'updates the selected process, but the state stays as added' do
          expect(sp_first.reload.repositioned?).to be_falsey
          expect(sp_first.reload.added?).to be_truthy
        end
      end

      context 'when selected process is in upgraded state' do
        before do
          sp_first.update(state: 'upgraded')
          subject.run
        end

        it 'updates the selected process' do
          expect(sp_first.reload.repositioned?).to be_falsey
          expect(sp_first.reload.upgraded?).to be_truthy
        end
      end

      context 'when selected process has already been repositioned once' do
        before do
          sp_first.update(state: 'repositioned')
          subject.run
        end

        it 'updates the selected process' do
          expect(sp_first.reload.repositioned?).to be_truthy
        end
      end
    end
  end
end