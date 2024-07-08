# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Workflow::Instance::Process::Create do
  describe '#create_process_instance' do
    let(:workflow_def) { create(:workflow_definition_workflow) }
    let(:wf_instance) { create(:workflow_instance_workflow, definition_id: workflow_def.id) }
    let(:subject) { Workflow::Instance::Process::Create.new(process_def, workflow_def, wf_instance) }
    let!(:selected_process) { create(:selected_process, workflow: workflow_def, process: process_def) }

    before do
      subject.create_process_instance
    end

    context 'when process definition is not recurring' do
      let(:process_def) { create(:workflow_definition_process) }

      it 'creates one process instance for that workflow' do
        expect(wf_instance.reload.processes.where(definition_id: process_def.id).count).to eq(1)
      end
    end

    context 'when process definition is recurring' do
      let(:process_def) { create(:workflow_definition_process, recurring: true, due_months: [1, 2, 3], duration: 1) }
      let(:workflow_def) { create(:workflow_definition_workflow, recurring: true) }

      it 'creates more than one process instance for that workflow' do
        expect(wf_instance.reload.processes.where(definition_id: process_def.id).count).to eq(process_def.due_months.count)
      end
    end
  end
end
