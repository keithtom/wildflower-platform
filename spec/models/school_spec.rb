# frozen_string_literal: true

require 'rails_helper'

RSpec.describe School, type: :model do
  subject { create(:school) }

  its(:external_identifier) { is_expected.not_to be_nil }

  describe '#active_partners' do
    let(:school) { create(:school) }
    let!(:active_partner_relationship) do
      create(:school_relationship, school:, start_date: Date.today, end_date: nil, role_list: Person::TL)
    end
    let!(:inactive_partner_relationship) do
      create(:school_relationship, school:, start_date: Date.today, end_date: Date.today + 1.year,
                                   role_list: Person::ETL)
    end

    it 'returns only active partners' do
      expect(school.active_partners).to include(active_partner_relationship.person)
      expect(school.active_partners).not_to include(inactive_partner_relationship.person)
    end
  end

  describe '#invited_partner' do
    let(:school) { create(:school) }
    let!(:active_partner_relationship) do
      create(:school_relationship, school:, start_date: Date.today, end_date: nil, role_list: Person::ETL)
    end
    let!(:invited_partner_relationship) do
      create(:school_relationship, school:, start_date: nil, end_date: nil, role_list: Person::TL)
    end

    it 'returns only active partners' do
      expect(school.invited_partners).to include(invited_partner_relationship.person)
      expect(school.invited_partners).not_to include(active_partner_relationship.person)
    end
  end
end
