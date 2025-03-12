require 'rails_helper'

RSpec.describe School::Remove, type: :service do
  let(:school) { create(:school, affiliated: true, directory_visible: true) }
  let(:person1) { create(:person) }
  let(:person2) { create(:person) }
  let!(:active_relationship1) { create(:school_relationship, school:, person: person1, start_date: Date.today, end_date: nil) }
  let!(:invited_relationship) { create(:school_relationship, school:, person: person2, start_date: nil, end_date: nil) }
  let!(:inactive_relationship) { create(:school_relationship, school:, end_date: Date.yesterday) }

  describe '#run' do
    it 'removes active partners and updates school attributes' do
      expect(School::RemovePartner).to receive(:run).with(person1, school, Time.zone.today).once
      expect(School::RemovePartner).to receive(:run).with(person2, school, Time.zone.today).once

      described_class.new(school).run

      expect(school.reload.affiliated).to be_falsey
      expect(school.reload.directory_visible).to be_falsey
    end

    it 'does not remove inactive partners' do
      expect(School::RemovePartner).not_to receive(:run).with(inactive_relationship.person, school, Time.zone.today)

      described_class.new(school).run
    end
  end
end
