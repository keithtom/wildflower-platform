require 'rails_helper'

RSpec.describe School::RemovePartner, type: :service do
  let(:school) { create(:school) }
  let(:person) { create(:person) }
  let!(:user) { create(:user, person_id: person.id) }
  let!(:school_relationship) { create(:school_relationship, school:, person:, start_date: Date.today, end_date: nil) }

  describe '.run' do
    context 'when the partner is successfully removed' do
      context 'when partner is only associated to one school' do
        it 'removes the partner from the school' do
          expect do
            School::RemovePartner.run(person, school)
          end.to change { school.reload.school_relationships.active.count }.by(-1)
        end

        it 'sets the end_date for the school_relationship' do
          School::RemovePartner.run(person, school)
          expect(school_relationship.reload.end_date).not_to be_nil
        end

        it 'removes person from the directory' do
          School::RemovePartner.run(person, school)
          expect(person.active).to be_falsey
        end

        it 'deletes user login' do
          School::RemovePartner.run(person, school)
          expect(user.reload.deleted?).to be_truthy
        end
      end

      context 'partner is associated to another school' do
        before do
          create(:school_relationship, school: create(:school), person:, start_date: Date.today, end_date: nil)
        end

        it 'removes the partner from the school' do
          expect do
            School::RemovePartner.run(person, school)
          end.to change { school.reload.school_relationships.active.count }.by(-1)
        end

        it 'sets the end_date for the school_relationship' do
          School::RemovePartner.run(person, school)
          expect(school_relationship.reload.end_date).not_to be_nil
        end

        it 'does NOT remove person from the directory' do
          School::RemovePartner.run(person, school)
          expect(person.reload.active).to be_truthy
        end

        it 'does NOT delete user login' do
          School::RemovePartner.run(person, school)
          expect(user.reload.deleted?).to be_falsey
        end
      end
    end

    context 'when the partner removal fails' do
      let!(:school_relationship) { nil }

      it 'raises an error' do
        expect do
          School::RemovePartner.run(person, school)
        end.to raise_error(StandardError, "Partner #{person.email} not associated to school #{school.name}")
      end
    end
  end
end
