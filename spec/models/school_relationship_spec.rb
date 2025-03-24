require 'rails_helper'

RSpec.describe SchoolRelationship, type: :model do
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
end
