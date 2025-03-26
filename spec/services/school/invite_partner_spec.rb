require 'rails_helper'

RSpec.describe School::InvitePartner, type: :service do
  let(:school) { create(:school, status: School::Status::OPEN) }
  let(:inviter) { create(:user) }
  let(:person_params) { { email: 'test@example.com', first_name: 'John', last_name: 'Doe' } }
  let(:school_relationship_params) { { title: 'Partner', start_date: '2023-01-01' } }

  describe '.run' do
    context 'when the request is valid' do
      it 'creates a new person and school relationship' do
        expect do
          described_class.run(person_params, school_relationship_params, school, inviter)
        end.to change(Person, :count).by(1)
                                     .and change(SchoolRelationship, :count).by(1)
      end

      it 'sends an invite email' do
        expect(OpenTlMailer).to receive(:invite_partner).and_call_original
        described_class.run(person_params, school_relationship_params, school, inviter)
      end
    end

    context 'when the email format is invalid' do
      let(:person_params) { { email: 'invalid-email', first_name: 'John', last_name: 'Doe' } }

      it 'raises an error' do
        expect do
          described_class.run(person_params, school_relationship_params, school, inviter)
        end.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Email must be a valid email address')
      end
    end

    context 'when the email is empty' do
      let(:person_params) { { email: '', first_name: 'John', last_name: 'Doe' } }

      it 'raises an error' do
        expect do
          described_class.run(person_params, school_relationship_params, school, inviter)
        end.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Email can\'t be blank, Email must be a valid email address')
      end
    end

    context 'when the email is nil' do
      let(:person_params) { { email: nil, first_name: 'John', last_name: 'Doe' } }

      it 'raises an error' do
        expect do
          described_class.run(person_params, school_relationship_params, school, inviter)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when the school status is invalid' do
      let(:school) { create(:school, status: nil) }

      it 'raises an error' do
        expect do
          described_class.run(person_params, school_relationship_params, school, inviter)
        end.to raise_error(StandardError, 'School must have status')
      end
    end
  end
end
