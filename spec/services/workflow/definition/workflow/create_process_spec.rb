require 'rails_helper'

RSpec.describe Workflow::Definition::Workflow::CreateProcess do
  describe '#run' do
    let(:workflow) { create(:workflow_definition_workflow) }
    let(:process_params) { { version: '2.0', title: 'Updated Process', description: 'This is an updated process'} }
    let(:subject) { Workflow::Definition::Workflow::CreateProcess.new(workflow, process_params) }

    context "workflow is published" do
      let(:workflow) { create(:workflow_definition_workflow, published_at: DateTime.now) }
        
      it "raises an error" do
        expect { subject.run }.to raise_error(Workflow::Definition::Workflow::CreateProcessError)
      end
    end
  
    context "happy path" do
      it "creates a selected process in the state: added" do
        process = subject.run
        selected_process = Workflow::Definition::SelectedProcess.find_by(workflow_id: workflow.id, process_id: process.id)
        expect(selected_process.added?).to be true
      end
    end
  end
end