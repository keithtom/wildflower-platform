require 'rails_helper'

RSpec.describe School::RemovePartner, type: :service do
  let(:school) { create(:school) }
  let(:person) { create(:person) }
  let(:user) { create(:user, person_id: person.id) }

  before do
    create(:school_relationship, school:, person:, start_date: Date.today)
  end

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
          school_relationship = SchoolRelationship.find_by(school:, person:)
          expect(school_relationship.end_date).not_to be_nil
        end

        it 'removes person from the directory' do
          School::RemovePartner.run(person, school)
          expect(person.active).to be_false
        end

        it 'deletes user login' do
          School::RemovePartner.run(person, school)
          expect(user).to be_nil
        end
      end

      context 'partner is associated to another school' do
        before do
          create(:school_relationship, school: create(:school), person:, start_date: Date.today)
        end

        it 'removes the partner from the school' do
          expect do
            School::RemovePartner.run(person, school)
          end.to change { school.people.count }.by(-1)
        end

        it 'sets the end_date for the school_relationship' do
          School::RemovePartner.run(person, school)
          school_relationship = SchoolRelationship.find_by(school:, person:)
          expect(school_relationship.end_date).not_to be_nil
        end

        it 'does NOT remove person from the directory' do
          School::RemovePartner.run(person, school)
          expect(person.active).to be_true
        end

        it 'does NOT delete user login' do
          School::RemovePartner.run(person, school)
          expect(user).to exist
        end
      end
    end

    context 'when the partner removal fails' do
      before do
        allow(school).to receive(:people).and_raise(StandardError, 'Something went wrong')
      end

      it 'raises an error' do
        expect do
          School::RemovePartner.run(person, school)
        end.to raise_error(StandardError, 'Something went wrong')
      end
    end
  end
end
