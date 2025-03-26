require 'rails_helper'

RSpec.describe Workflow::Instance::StepAssignment, type: :model do
  describe 'scopes' do
    describe '.for_workflow' do
      let(:workflow1) { create(:workflow_instance_workflow) }
      let(:workflow2) { create(:workflow_instance_workflow) }
      let(:process1) { create(:workflow_instance_process, workflow: workflow1) }
      let(:process2) { create(:workflow_instance_process, workflow: workflow2) }
      let(:step1) { create(:workflow_instance_step, process: process1) }
      let(:step2) { create(:workflow_instance_step, process: process2) }
      let(:person) { create(:person) }

      let!(:assignment1) { create(:workflow_instance_step_assignment, step: step1, assignee: person) }
      let!(:assignment2) { create(:workflow_instance_step_assignment, step: step2, assignee: person) }

      context 'when passing a single workflow ID' do
        it 'returns assignments for the specified workflow' do
          result = described_class.for_workflow(workflow1.id)
          expect(result).to include(assignment1)
          expect(result).not_to include(assignment2)
        end
      end

      context 'when passing an array of workflow IDs' do
        it 'returns assignments for all specified workflows' do
          result = described_class.for_workflow([workflow1.id, workflow2.id])
          expect(result).to include(assignment1, assignment2)
        end
      end

      context 'when passing a non-existent workflow ID' do
        it 'returns no assignments' do
          result = described_class.for_workflow(-1)
          expect(result).to be_empty
        end
      end

      context 'when passing an empty array' do
        it 'returns no assignments' do
          result = described_class.for_workflow([])
          expect(result).to be_empty
        end
      end

      context 'when passing nil' do
        it 'returns no assignments' do
          result = described_class.for_workflow(nil)
          expect(result).to be_empty
        end
      end
    end
  end
end
