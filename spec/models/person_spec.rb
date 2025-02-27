# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person, type: :model do
  subject { build(:person) }

  describe '#external_identifier' do
    subject { create(:person) }

    its(:external_identifier) { is_expected.not_to be_nil }
  end

  describe '#subroles' do
    before do
      subject.tl_role_list.add 'finance'
      subject.foundation_role_list.add 'school supports'
      subject.rse_role_list.add 'fundraising'
      subject.og_role_list.add 'ssj guide'
      subject.save!
    end

    its(:subroles) { is_expected.to contain_exactly 'finance', 'school supports', 'fundraising', 'ssj guide' }
  end

  describe 'associations' do
    describe 'user association' do
      let(:person) { create(:person) }
      let(:user) { create(:user) }

      it 'can have one user' do
        expect(Person.reflect_on_association(:user).macro).to eq :has_one
      end

      it 'allows setting a user' do
        person.user = user
        expect(person.save).to be true
        expect(person.reload.user).to eq user
      end

      it 'allows creating a person with a user' do
        new_person = create(:person, user:)
        expect(new_person.user).to eq user
        expect(user.reload.person).to eq new_person
      end

      it 'allows removing a user association' do
        person.user = user
        person.save!

        person.user = nil
        expect(person.save).to be true
        expect(person.reload.user).to be_nil
      end

      it 'preserves the user record when person is deleted' do
        person.user = user
        person.save!
        user_id = user.id

        person.destroy
        expect(User.find_by(id: user_id)).to be_present
      end
    end
  end

  describe '#sync_user_email' do
    let(:person) { create(:person) }

    context 'when the user is present' do
      let!(:user) { create(:user, person:) }

      it 'syncs the user email to the person email' do
        person.update(email: 'new@email.com')
        expect(user.reload.email).to eq('new@email.com')
      end
    end

    context 'when the user is not present' do
      let!(:user) { create(:user) }

      it 'does not sync the user email to the person email if the user is not present' do
        person.update(email: 'new@email.com')
        expect(user.reload.email).not_to eq('new@email.com')
      end
    end
  end
end
