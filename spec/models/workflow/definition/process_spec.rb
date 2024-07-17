require 'rails_helper'

RSpec.describe Workflow::Instance::Process, type: :model do
  describe ".validate_recurring" do
    context 'process is recurring' do
      context 'prev version is recurring' do
        let!(:prev_version_process) { create(:workflow_definition_process, recurring: true) }

        it 'does not raise an error' do
          expect{ create(:workflow_definition_process, previous_version: prev_version_process, recurring: true) }.not_to raise_error
        end
      end

      context 'prev version is NOT recurring' do
        let!(:prev_version_process) { create(:workflow_definition_process, recurring: false) }

        it 'does not raise an error' do
          expect{ create(:workflow_definition_process, previous_version: prev_version_process, recurring: true) }.to raise_error
        end
      end
    end
    context 'process is not recurring' do
      context 'prev version is recurring' do
        let!(:prev_version_process) { create(:workflow_definition_process, recurring: true) }

        it 'does not raise an error' do
          expect{ create(:workflow_definition_process, previous_version: prev_version_process, recurring: false) }.to raise_error
        end
      end

      context 'prev version is NOT recurring' do
        let!(:prev_version_process) { create(:workflow_definition_process, recurring: false) }

        it 'does not raise an error' do
          expect{ create(:workflow_definition_process, previous_version: prev_version_process, recurring: false) }.not_to raise_error
        end
      end
    end
  end
end
