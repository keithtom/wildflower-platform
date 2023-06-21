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

  describe "as an OG" do
    subject { create(:og_person) }

    it "have many SSJ teams" do
      expect(subject.og_teams.count).to eq(3)
    end
  end

  describe "as a foundation partner" do
  end

  describe "as a TL" do
  end

  describe "as a ETL" do
  end

  describe "as a TL, OG, foundation partner" do
  end
end
