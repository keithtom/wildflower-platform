require 'rails_helper'

RSpec.describe SSJ::Team, type: :model do
  describe "returns all the members" do
    subject { create(:ssj_team) }
    let(:ops_guide) { subject.ops_guide }
    its(:people) { is_expected.to_not be_empty }
    its(:people) { is_expected.to include(ops_guide) }
  end
end
