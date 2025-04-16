require 'rails_helper'

RSpec.describe SchoolRelationship, type: :model do
  let(:school) { create(:school) }
  let(:person) { create(:person) }

  describe 'callbacks' do
    describe '#add_role_to_person' do
      let(:person) { create(:person, role_list: [Person::ETL]) }
      let(:school) { create(:school) }
      let(:role) { 'Teacher Leader' }

      context 'on create' do
        it 'adds roles to person when created with role_list' do
          expect do
            create(:school_relationship, person:, school:, role_list: [role])
          end.to change { person.reload.role_list.count }.by(1)
        end

        it 'does not add roles when role_list is empty' do
          expect do
            create(:school_relationship, person:, school:, role_list: [])
          end.not_to change { person.reload.role_list.count }
        end
      end

      context 'on update' do
        let!(:relationship) { create(:school_relationship, person:, school:) }

        it 'adds new roles when role_list is updated' do
          expect do
            relationship.role_list.add(role)
            relationship.save!
          end.to change { person.reload.role_list.count }.by(1)
        end

        it 'does not add roles when role_list is cleared' do
          relationship.role_list.add(role)
          relationship.save!
          expect do
            relationship.role_list.remove(role)
            relationship.save!
          end.not_to change { person.reload.roles.count }
        end
      end
    end
  end

  describe 'unique index on person_id and school_id' do
    context 'when creating active relationships' do
      it 'allows one active relationship per person-school pair' do
        create(:school_relationship, person:, school:, end_date: nil)
        expect do
          create(:school_relationship, person:, school:, end_date: nil)
        end.to raise_error(ActiveRecord::RecordNotUnique)
      end

      it 'allows multiple relationships if one has an end date' do
        create(:school_relationship, person:, school:, end_date: Date.today)
        expect do
          create(:school_relationship, person:, school:, end_date: nil)
        end.not_to raise_error
      end

      it 'allows multiple relationships if one is soft-deleted' do
        create(:school_relationship, person:, school:, end_date: nil).destroy
        expect do
          create(:school_relationship, person:, school:, end_date: nil)
        end.not_to raise_error
      end

      it 'allows multiple relationships with different end dates' do
        create(:school_relationship, person:, school:, end_date: Date.today)
        expect do
          create(:school_relationship, person:, school:, end_date: Date.tomorrow)
        end.not_to raise_error
      end
    end

    context 'when updating relationships' do
      let!(:relationship) { create(:school_relationship, person:, school:, end_date: nil) }
      let!(:other_relationship) { create(:school_relationship, person:, school:, end_date: Date.today) }

      it 'prevents removing end_date if another active relationship exists' do
        expect do
          other_relationship.update!(end_date: nil)
        end.to raise_error(ActiveRecord::RecordNotUnique)
      end

      it 'allows removing end_date if no other active relationship exists' do
        relationship.destroy
        expect do
          other_relationship.update!(end_date: nil)
        end.not_to raise_error
      end

      it 'allows soft-deleting an active relationship' do
        expect do
          relationship.destroy
        end.not_to raise_error
      end
    end
  end
end
