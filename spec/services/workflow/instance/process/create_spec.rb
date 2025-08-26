# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Workflow::Instance::Process::Create do
  let(:workflow_def) { create(:workflow_definition_workflow) }
  let(:wf_instance) { create(:workflow_instance_workflow, definition_id: workflow_def.id) }
  let(:subject) { Workflow::Instance::Process::Create.new(process_def, workflow_def, wf_instance) }
  let!(:selected_process) { create(:selected_process, workflow: workflow_def, process: process_def) }

  describe '#create_process_instance' do
    context 'when process definition is not recurring' do
      let(:process_def) { create(:workflow_definition_process) }

      it 'creates one process instance for that workflow' do
        subject.create_process_instance
        expect(wf_instance.reload.processes.where(definition_id: process_def.id).count).to eq(1)
      end
    end

    context 'when process definition is recurring' do
      let(:process_def) { create(:workflow_definition_process, recurring: true, due_months: [1, 2, 3], duration: 1) }
      let(:workflow_def) { create(:workflow_definition_workflow, recurring: true) }

      it 'creates more than one process instance for that workflow' do
        subject.create_process_instance
        expect(wf_instance.reload.processes.where(definition_id: process_def.id).count).to eq(process_def.due_months.count)
      end

      context 'for publishing creations' do
        let(:subject) { Workflow::Instance::Process::Create.new(process_def, workflow_def, wf_instance, true) }

        before do
          allow_any_instance_of(OpenSchools::DateCalculator).to receive(:due_date).with(1).and_return(Time.zone.today)
          allow_any_instance_of(OpenSchools::DateCalculator).to receive(:due_date).with(2).and_return(Time.zone.tomorrow)
          allow_any_instance_of(OpenSchools::DateCalculator).to receive(:due_date).with(3).and_return(Time.zone.yesterday)
        end

        it 'only creates the recurring processes in the future' do
          subject.create_process_instance
          expect(wf_instance.reload.processes.where(definition_id: process_def.id).count).not_to eq(process_def.due_months.count)
          expect(wf_instance.reload.processes.where(definition_id: process_def.id).count).to eq(1)
        end
      end

      context 'when process instances already exist' do
        let(:process_def) { create(:workflow_definition_process, recurring: true, due_months: [1, 2], duration: 1) }
        let(:workflow_def) { create(:workflow_definition_workflow, recurring: true) }
        let!(:existing_process) do
          create(:workflow_instance_process,
                 definition: process_def,
                 workflow: wf_instance,
                 due_date: Date.new(2025, 1, 31))
        end

        before do
          allow_any_instance_of(OpenSchools::DateCalculator).to receive(:due_date).with(1).and_return(Date.new(2025, 1,
                                                                                                                31))
          allow_any_instance_of(OpenSchools::DateCalculator).to receive(:due_date).with(2).and_return(Date.new(2025, 2,
                                                                                                                28))
        end

        it 'skips creating duplicate process instances for the same workflow and due date' do
          expect do
            subject.create_process_instance
          end.to change { wf_instance.reload.processes.where(definition_id: process_def.id).count }.by(1)

          # Should only create the second process (due_date: 2) since the first already exists
          expect(wf_instance.processes.where(definition_id: process_def.id,
                                             due_date: Date.new(2025, 1,
                                                                 31)).count).to eq(1)
          expect(wf_instance.processes.where(definition_id: process_def.id,
                                             due_date: Date.new(2025, 2,
                                                                 28)).count).to eq(1)
        end

        it 'does not create duplicate process instances when run multiple times' do
          # First run
          subject.create_process_instance
          initial_count = wf_instance.reload.processes.where(definition_id: process_def.id).count

          # Second run
          subject.create_process_instance
          final_count = wf_instance.reload.processes.where(definition_id: process_def.id).count

          expect(final_count).to eq(initial_count)
        end
      end
    end
  end

  describe '#create_step_instances' do
    let(:process_def) { create(:workflow_definition_process) }
    let!(:step_definition) { create(:workflow_definition_step, process: process_def) }

    context 'when step instances already exist' do
      let!(:existing_process) { create(:workflow_instance_process, definition: process_def, workflow: wf_instance) }
      let!(:existing_step) do
        create(:workflow_instance_step,
               definition: step_definition,
               process: existing_process)
      end

      it 'skips creating duplicate step instances for the same process and definition' do
        expect do
          subject.create_step_instances
        end.not_to change { existing_process.reload.steps.count }

        expect(existing_process.steps.where(definition_id: step_definition.id).count).to eq(1)
      end

      it 'does not create duplicate step instances when run multiple times' do
        # First run
        subject.create_step_instances
        initial_count = existing_process.reload.steps.count

        # Second run
        subject.create_step_instances
        final_count = existing_process.reload.steps.count

        expect(final_count).to eq(initial_count)
      end
    end

    context 'when no step instances exist' do
      let!(:existing_process) { create(:workflow_instance_process, definition: process_def, workflow: wf_instance) }

      before do
        subject.instance_variable_set(:@process_instances, [existing_process])
      end

      it 'creates step instances for each step definition' do
        expect do
          subject.create_step_instances
        end.to change { existing_process.reload.steps.count }.by(process_def.steps.count)

        expect(existing_process.steps.where(definition_id: step_definition.id).count).to eq(1)
      end
    end
  end

  describe '#run' do
    context 'when process definition is recurring' do
      let(:process_def) { create(:workflow_definition_process, recurring: true, due_months: [1, 2, 3], duration: 1) }
      let(:workflow_def) { create(:workflow_definition_workflow, recurring: true) }
      let!(:step) { create(:workflow_definition_step, process: process_def) }

      it 'creates steps for each process' do
        expect(process_def.steps.count).to be(1)
        subject.run
        wf_instance.processes.each do |process|
          expect(process.steps.count).to eq(process_def.steps.count)
        end
      end
    end
  end
end
