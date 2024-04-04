require 'rails_helper'

RSpec.describe Workflow::Definition::Workflow::NewVersion, type: :service do
  let(:workflow) { create(:workflow_definition_workflow, version: "v1") }
  let(:new_version_service) { described_class.new(workflow) }

  before do
    3.times do
      Workflow::Definition::SelectedProcess.create(workflow_id: workflow.id, process_id: create(:workflow_definition_process).id)
    end
  end

  describe "#run" do
    it "creates a new version of the workflow" do
      expect { new_version_service.run }.to change { Workflow::Definition::Workflow.count }.by(1)
    end

    it "creates new selected processes" do
      expect { new_version_service.run }.to change { Workflow::Definition::SelectedProcess.count }.by(workflow.selected_processes.count)
    end

    it "clones the attributes for the previous version" do
      new_version = new_version_service.run
      expect(new_version).to be_an_instance_of(Workflow::Definition::Workflow)
      expect(new_version.previous_version_id).to eq(workflow.id)
      expect(new_version.version).to eq("v2")

      workflow.selected_processes.each do |sp|
        cloned_selected_process = new_version.selected_processes.find_by(previous_version_id: sp.id)
        expect(cloned_selected_process).to be_an_instance_of(Workflow::Definition::SelectedProcess)
        expect(cloned_selected_process.workflow_id).to eq(new_version.id)
        expect(cloned_selected_process.process_id).to eq(sp.process_id)
      end
    end
  end
end