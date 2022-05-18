require 'rails_helper'

describe V1::Advice::StakeholderSerializer do
  let(:stakeholder) { create(:advice_stakeholder) }
  before do
    create(:advice_record, stakeholder: stakeholder, decision: stakeholder.decision, status: "Hello")
  end

  subject { described_class.new(stakeholder).serializable_hash }

  its(%i[data attributes]) { is_expected.to have_key(:name) }
  its(%i[data relationships]) { is_expected.to have_key(:decision) }
  its(%i[data relationships]) { is_expected.to_not have_key(:activites) }

  # add ability to do eager loading
  # no activities unless eager loaded

  describe "when activities are included" do
    # its(%i[data relationships]) { is_expected.to have_key(:activites) }
  end
end
