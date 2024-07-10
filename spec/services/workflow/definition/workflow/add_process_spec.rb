require 'rails_helper'

RSpec.describe Workflow::Definition::Workflow::AddProcess do
  describe '#run' do
    let(:workflow) { create(:workflow_definition_workflow) }
    let(:process) { create(:workflow_definition_process) }
    let!(:selected_process) { create(:selected_process, workflow: workflow, process: process) }
    let(:position) { 50 }
    let(:subject) { Workflow::Definition::Workflow::AddProcess.new(workflow, process, position) }

    context "workflow is published" do
      let(:workflow) { create(:workflow_definition_workflow, published_at: DateTime.now) }

      it "raises an error" do
        expect { subject.run }.to raise_error(Workflow::Definition::Workflow::AddProcessError)
      end
    end

    context 'position is not set' do
      let(:position) { nil }

      context 'with non recurring process' do
        it "raises an error" do
          expect { subject.run }.to raise_error(Workflow::Definition::Workflow::AddProcessError)
        end
      end

      context 'with recurring process' do
        before do
          process.recurring = true
          process.save
          workflow.recurring = true
          workflow.save
        end

        it "does not raise an error" do
          expect { subject.run }.not_to raise_error(Workflow::Definition::Workflow::AddProcessError)
        end
      end
    end
 
    context "happy path" do
      it "only creates one new selected process" do
        expect { subject.run }.to change {Workflow::Definition::SelectedProcess.count}.by(1)
      end

      it "returns a selected process in the state: added" do
        selected_process = subject.run
        expect(selected_process.added?).to be true
      end
    end
  end
end