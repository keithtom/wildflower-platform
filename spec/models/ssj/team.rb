require 'rails_helper'

RSpec.describe SSJ::Team, type: :model do
  describe "returns all the members" do
    subject { build(:ssj_team, :with_partners) }
    let(:ops_guide) { subject.ops_guide }
    its(:members) { is_expected.to_not be_empty }
    its(:members) { is_expected.to include(ops_guide) }
  end
end
