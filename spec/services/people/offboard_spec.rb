require 'rails_helper'

RSpec.describe People::Offboard, type: :service do
  let(:end_date) { Date.today }
  let(:person) { create(:person, active: true) }
  let!(:user) { create(:user, person:) }
  let!(:school1) { create(:school) }
  let!(:school2) { create(:school) }
  let!(:school_relationship1) { create(:school_relationship, person:, school: school1, end_date: nil) }
  let!(:school_relationship2) { create(:school_relationship, person:, school: school2, end_date: nil) }
  let!(:assignment1) { create(:workflow_instance_step_assignment, assignee: person) }
  let!(:assignment2) { create(:workflow_instance_step_assignment, assignee: person) }
  let!(:completed_assignment) do
    create(:workflow_instance_step_assignment, assignee: person, completed_at: Time.current)
  end

  describe '#run' do
    subject { described_class.new(person, end_date).run }

    context 'when user has a person record' do
      it 'deactivates the person' do
        expect { subject }.to change { person.reload.active }.from(true).to(false)
      end

      it 'sets the person end_date' do
        expect { subject }.to change { person.reload.end_date }.from(nil).to(end_date)
      end

      it 'destroys incomplete assignments' do
        expect { subject }.to change { person.assignments.incomplete.count }.from(2).to(0)
      end

      it 'does not destroy completed assignments' do
        expect { subject }.not_to change { person.assignments.complete.count }
      end

      it 'sets end_date for all active school relationships' do
        subject
        expect(school_relationship1.reload.end_date).to eq(end_date)
        expect(school_relationship2.reload.end_date).to eq(end_date)
      end

      it 'destroys the user record' do
        expect { subject }.to change { User.count }.by(-1)
      end
    end

    context 'when a person record does not have a user record' do
      let!(:user) { nil }

      it 'does not destroy any user record, and does not raise an error' do
        expect { subject }.not_to change { User.count }
        expect { subject }.not_to raise_error
      end
    end
  end
end
