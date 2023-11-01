require 'rails_helper'

RSpec.describe SSJ::Team, type: :model do
    describe "returns all the members" do
    subject { create(:ssj_team_with_members) }
    let(:ops_guide) { subject.ops_guide }
    its(:people) { is_expected.to_not be_empty }
    its(:people) { is_expected.to include(ops_guide) }
  end

    describe '#temp_name' do
    let(:team) { create(:ssj_team) }

        context 'when the team has no partner members' do
      it 'returns a default name' do
        expect(team.temp_name).to eq('school')
      end
    end

        context 'when the team has partner members with no info' do
      let(:partner1) { create(:person, first_name: 'John') }
      let(:partner2) { create(:person, first_name: 'Jane') }

      before do
        SSJ::TeamMember.create!(ssj_team: team, person: partner1, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
        SSJ::TeamMember.create!(ssj_team: team, person: partner2, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
      end

      it 'returns a name based on the partner members' do
        expect(team.temp_name).to eq('John-Jane-school')
      end
    end

        context 'when the team has partner members' do
      let(:partner1) { create(:person, first_name: 'John', address: build(:address, state: 'CA')) }
      let(:partner2) { create(:person, first_name: 'Jane', classroom_age_list: ['K', '1']) }

      before do
        SSJ::TeamMember.create!(ssj_team: team, person: partner1, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
        SSJ::TeamMember.create!(ssj_team: team, person: partner2, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
      end

      it 'returns a name based on the partner members' do
        expect(team.temp_name).to eq('John-Jane-CA-K-1-school')
      end
    end

        context 'when team member does not have first name' do
      let(:partner1) { create(:person, first_name: nil) }

      before do
        SSJ::TeamMember.create!(ssj_team: team, person: partner1, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
      end

      it 'returns a name based on the partner members' do
        expect(team.temp_name).to eq('school')
      end
    end
  end
end
