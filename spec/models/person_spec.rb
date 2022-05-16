# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Person, type: :model do
  subject { create(:person) }

  its(:external_identifier) { is_expected.to_not be_nil }

  describe "#subroles" do
    subject { build(:person) }
    before do
      subject.tl_roles.add "finance"
      subject.foundation_roles.add "school supports"
      subject.rse_roles.add "fundraising"
      subject.og_roles.add "ssj guide"
    end

    its(:subroles) { is_expected.to == ["finance", "school supports", "fundraising", "ssj guide"] }
  end
end
