# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Workflow::Instance::Dependency::Create do
  let(:workflow_def) { create(:workflow_definition_workflow) }
  let(:wf_instance) { create(:workflow_instance_workflow, definition_id: workflow_def.id) }
  let(:process_def) { create(:workflow_definition_process) }
  let(:prereq_process_def) { create(:workflow_definition_process) }
  let(:workable_process) { create(:workflow_instance_process, definition: process_def, workflow: wf_instance) }
  let(:prereq_process) { create(:workflow_instance_process, definition: prereq_process_def, workflow: wf_instance) }
  let(:dependency_def) do
    create(:workflow_definition_dependency,
           workflow: workflow_def,
           workable: process_def,
           prerequisite_workable: prereq_process_def)
  end
  let(:subject) do
    Workflow::Instance::Dependency::Create.new(dependency_def, wf_instance, workable_process, prereq_process)
  end

  describe '#run' do
    context 'when dependency instance already exists' do
      let!(:existing_dependency) do
        create(:workflow_instance_dependency,
               definition: dependency_def,
               workflow: wf_instance,
               workable: workable_process,
               prerequisite_workable: prereq_process)
      end

      it 'returns early without creating a new dependency instance' do
        expect do
          subject.run
        end.not_to change { dependency_def.instances.count }

        expect(dependency_def.instances.where(
          workflow: wf_instance,
          workable: workable_process,
          prerequisite_workable: prereq_process
        ).count).to eq(1)
      end

      it 'logs information about the existing dependency' do
        expect(Rails.logger).to receive(:info).with(
          /dependency instance already exists for dependency def #{dependency_def.id}/
        )

        subject.run
      end
    end

    context 'when dependency instance does not exist' do
      it 'creates a new dependency instance' do
        expect do
          subject.run
        end.to change { dependency_def.instances.count }.by(1)

        new_dependency = dependency_def.instances.last
        expect(new_dependency.workflow).to eq(wf_instance)
        expect(new_dependency.workable).to eq(workable_process)
        expect(new_dependency.prerequisite_workable).to eq(prereq_process)
      end
    end

    context 'when run multiple times' do
      it 'does not create duplicate dependency instances' do
        # First run
        subject.run
        initial_count = dependency_def.instances.count

        # Second run
        subject.run
        final_count = dependency_def.instances.count

        expect(final_count).to eq(initial_count)
      end
    end
  end

  describe '#validate_dependency_instance_already_exists' do
    context 'when dependency instance exists' do
      let!(:existing_dependency) do
        create(:workflow_instance_dependency,
               definition: dependency_def,
               workflow: wf_instance,
               workable: workable_process,
               prerequisite_workable: prereq_process)
      end

      it 'returns true' do
        expect(subject.validate_dependency_instance_already_exists).to be true
      end

      it 'logs information about the existing dependency' do
        expect(Rails.logger).to receive(:info).with(
          /dependency instance already exists for dependency def #{dependency_def.id}/
        )

        subject.validate_dependency_instance_already_exists
      end
    end

    context 'when dependency instance does not exist' do
      it 'returns false' do
        expect(subject.validate_dependency_instance_already_exists).to be false
      end
    end
  end
end
