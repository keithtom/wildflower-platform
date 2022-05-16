# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person, type: :model do
  subject { build(:person) }


  describe "#external_identifier" do
    subject { create(:person) }
    its(:external_identifier) { is_expected.to_not be_nil }
  end

  describe "#subroles" do
    before do
      subject.tl_role_list.add "finance"
      subject.foundation_role_list.add "school supports"
      subject.rse_role_list.add "fundraising"
      subject.og_role_list.add "ssj guide"
      subject.save!
    end

    its(:subroles) { is_expected.to contain_exactly "finance", "school supports", "fundraising", "ssj guide" }
  end
end
