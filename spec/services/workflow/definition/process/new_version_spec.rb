# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Workflow::Definition::Process::NewVersion, type: :service do
  let(:workflow) { create(:workflow_definition_workflow) }
  let(:process) { create(:workflow_definition_process, version: 'v1') }
  let(:new_version_service) { described_class.new(workflow, process) }
  let!(:selected_process) { Workflow::Definition::SelectedProcess.create!(workflow_id: workflow.id, process_id: process.id, state: 'replicated')}
  let!(:step_with_document) { create(:workflow_definition_step, process: process) }
  let!(:step_with_decision) { create(:workflow_definition_step_decision, process: process) }
  let!(:dependency) do
    Workflow::Definition::Dependency.create!(
      workflow_id: workflow.id,
      workable_type: Workflow::Definition::Process,
      workable_id: process.id,
      prerequisite_workable_id: create(:workflow_definition_process).id,
      prerequisite_workable_type: Workflow::Definition::Process
    )
  end
  let!(:dependency_prerequisite) do
    Workflow::Definition::Dependency.create!(
      workflow_id: workflow.id,
      workable_id: create(:workflow_definition_process).id,
      workable_type: Workflow::Definition::Process,
      prerequisite_workable_id: process.id,
      prerequisite_workable_type: Workflow::Definition::Process
    )
  end

  describe '#run' do
    it 'creates a new process version that points to the old one, all other attributes are the same' do
      new_version = new_version_service.run
      expect(new_version.previous_version).to eq(process)
      expect(new_version.version).to eq('v2')
      expect(new_version.title).to eq(process.title)
      expect(new_version.description).to eq(process.description)
    end

    it 'clones the process steps' do
      new_version = new_version_service.run
      expect(new_version.steps.count).to eq(2)
      new_step_with_decision = new_version.steps.where(kind: Workflow::Definition::Step::DECISION).first
      new_step_with_document = new_version.steps.where(kind: Workflow::Definition::Step::DEFAULT).first

      expect(new_step_with_decision.decision_options.first.description).to eq(step_with_decision.decision_options.first.description)
      expect(new_step_with_document.documents.first.link).to eq(step_with_document.documents.first.link)
    end

    it 'updates the dependency to the new process version' do
      new_version = new_version_service.run
      expect(dependency.reload.workable).to eq(new_version)
    end

    it 'updates the prerequisite to the new process version' do
      new_version = new_version_service.run
      expect(dependency_prerequisite.reload.prerequisite_workable).to eq(new_version)
    end

    it 'updates the selected process to the new process version' do
      new_version = new_version_service.run
      expect(selected_process.reload.process.id).to eq(new_version.id)
    end

    it 'creates a new process that is not published' do
      new_version = new_version_service.run
      expect(new_version.published_at).to be_nil
    end
  end
end
