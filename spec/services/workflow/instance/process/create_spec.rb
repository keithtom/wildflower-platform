# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Workflow::Instance::Process::Create do
  describe '#calc_due_date' do
    let(:subject) { Workflow::Instance::Process::Create.new(nil, nil, nil) }

    context 'when it is the fall' do
      it 'is beginning of school year' do
        expect(subject.calc_due_date(9)).to eq(Date.new(2024, 9, 30))
      end
    end

    context 'when it is the summer' do
      it 'is the end of the school year' do
        expect(subject.calc_due_date(8)).to eq(Date.new(2025, 8, 31))
      end
    end

    context 'when it is the beginning of the year' do
      it 'is the end of the school year' do
        expect(subject.calc_due_date(1)).to eq(Date.new(2025, 1, 31))
      end
    end

    context 'when it is the end of the year' do
      it 'is the beginning of the school year' do
        expect(subject.calc_due_date(12)).to eq(Date.new(2024, 12, 31))
      end
    end
  end

  describe '#calc_suggested_start_date' do
    let(:subject) { Workflow::Instance::Process::Create.new(nil, nil, nil) }

    context 'when due date is in a month that has 31 days' do
      let(:due_date) { Date.new(2024, 12, 31) }

      context 'when duration is 1 month' do
        it 'is the start of the same month' do
          expect(subject.calc_suggested_start_date(due_date, 1)).to eq(due_date.beginning_of_month)
        end
      end

      context 'when duration is 3 months' do
        it 'is 3 months beforehand' do
          expect(subject.calc_suggested_start_date(due_date, 3)).to eq(Date.new(2024, 10, 1))
        end
      end

      context 'when duration is 12 months' do
        it 'is 12 months beforehand' do
          expect(subject.calc_suggested_start_date(due_date, 12)).to eq(due_date - 1.year + 1.day)
        end
      end
    end

    context 'when due date is in a month that has 30 days' do
      let(:due_date) { Date.new(2024, 6, 30) }

      context 'when duration is 1 month' do
        it 'is the start of the same month' do
          expect(subject.calc_suggested_start_date(due_date, 1)).to eq(due_date.beginning_of_month)
        end
      end

      context 'when duration is 3 months' do
        it 'is 3 months beforehand' do
          expect(subject.calc_suggested_start_date(due_date, 3)).to eq(Date.new(2024, 4, 1))
        end
      end

      context 'when duration is 12 months' do
        it 'is 12 months beforehand' do
          expect(subject.calc_suggested_start_date(due_date, 12)).to eq(due_date - 1.year + 1.day)
        end
      end
    end

    context 'when due date is in a month that has 28 days' do
      let(:due_date) { Date.new(2024, 2, 28) }

      context 'when duration is 1 month' do
        it 'is the start of the same month' do
          expect(subject.calc_suggested_start_date(due_date, 1)).to eq(due_date.beginning_of_month)
        end
      end

      context 'when duration is 3 months' do
        it 'is 3 months beforehand' do
          expect(subject.calc_suggested_start_date(due_date, 3)).to eq(Date.new(2023, 12, 1))
        end
      end

      context 'when duration is 12 months' do
        it 'is 12 months beforehand' do
          expect(subject.calc_suggested_start_date(due_date, 12)).to eq(due_date - 1.year + 1.day)
        end
      end
    end
  end

  describe '#calc_process_instance' do
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

      it 'creates more than one process instance for that workflow' do
        expect(wf_instance.reload.processes.where(definition_id: process_def.id).count).to eq(process_def.due_months.count)
      end
    end
  end
end
