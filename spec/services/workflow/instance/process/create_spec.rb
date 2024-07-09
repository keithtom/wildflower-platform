# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Workflow::Instance::Process::Create do
  describe '#create_process_instance' do
    let(:workflow_def) { create(:workflow_definition_workflow) }
    let(:wf_instance) { create(:workflow_instance_workflow, definition_id: workflow_def.id) }
    let(:subject) { Workflow::Instance::Process::Create.new(process_def, workflow_def, wf_instance) }
    let!(:selected_process) { create(:selected_process, workflow: workflow_def, process: process_def) }

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
    end
  end
end
