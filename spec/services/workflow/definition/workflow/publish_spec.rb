require 'rails_helper'

RSpec.describe Workflow::Definition::Workflow::Publish do
  describe '#rollout_adds' do
    context 'when it is being added to the front of the list' do
      it 'adds a new process to the workflow instance' do
      end
    end
    context 'when the previous process by position has been started' do
      it 'does not add a process to the workflow instance' do
      end
    end
    context 'when the previous process by position has not been started' do
      it 'adds a new process to the workflow instance' do
      end
    end
    it 'should add the workflow instance to the rollout' do
      # Create a new instance of the workflow
      workflow_instance = Workflow::Instance.new

      # Call the rollout_adds method
      subject.rollout_adds(workflow_instance)

      # Assert that the workflow instance is added to the rollout
      expect(Workflow::Rollout).to have_received(:add).with(workflow_instance)
    end
  end
end