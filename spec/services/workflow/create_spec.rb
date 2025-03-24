require 'rails_helper'

RSpec.describe Workflow::Create do
  describe '.call' do
    let(:definition) { create(:workflow_definition_workflow) }
    let(:school) { create(:school) }
    let(:service) { described_class.call(definition_id: definition.id, school_id: school.external_identifier) }

    context 'when all parameters are valid' do
      it 'creates a new workflow' do
        expect { service }.to change(Workflow::Instance::Workflow, :count).by(1)
      end

      it 'associates the workflow with the correct school and definition' do
        workflow = service
        expect(workflow.school).to eq(school)
        expect(workflow.definition).to eq(definition)
      end

      it 'enqueues the initialization job' do
        expect(Workflow::InitializeWorkflowJob).to receive(:perform_later)
        service
      end

      it 'enqueues the notification email' do
        expect(SchoolMailer).to receive(:notify_partners_new_workflow)
          .with(school.id)
          .and_return(double(deliver_later: true))
        service
      end
    end

    context 'when the workflow definition is not found' do
      let(:service) { described_class.call(definition_id: -1, school_id: school.external_identifier) }

      it 'raises a ServiceError with not_found status' do
        expect { service }.to raise_error(Workflow::ServiceError) do |error|
          expect(error.message).to eq('School or workflow definition not found')
          expect(error.status).to eq(:not_found)
        end
      end
    end

    context 'when the school is not found' do
      let(:service) { described_class.call(definition_id: definition.id, school_id: 'invalid-id') }

      it 'raises a ServiceError with not_found status' do
        expect { service }.to raise_error(Workflow::ServiceError) do |error|
          expect(error.message).to eq('School or workflow definition not found')
          expect(error.status).to eq(:not_found)
        end
      end
    end

    context 'when workflow creation fails validation' do
      before do
        allow(Workflow::Instance::Workflow).to receive(:create!)
          .and_raise(ActiveRecord::RecordInvalid.new(Workflow::Instance::Workflow.new))
      end

      it 'raises a ServiceError with unprocessable_entity status' do
        expect { service }.to raise_error(Workflow::ServiceError) do |error|
          expect(error.status).to eq(:unprocessable_entity)
        end
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(Workflow::Instance::Workflow).to receive(:create!)
          .and_raise(StandardError.new('Unexpected error'))
      end

      it 'raises a ServiceError with internal_server_error status' do
        expect { service }.to raise_error(Workflow::ServiceError) do |error|
          expect(error.message).to eq('An unexpected error occurred')
          expect(error.status).to eq(:internal_server_error)
        end
      end
    end

    context 'transaction handling' do
      before do
        allow(Workflow::Instance::Workflow).to receive(:create!)
          .and_raise(StandardError.new('Unexpected error'))
      end

      it 'rolls back workflow creation if background jobs fail' do
        expect { service }.to raise_error(Workflow::ServiceError)
        expect(Workflow::Instance::Workflow.count).to eq(0)
      end
    end
  end
end
