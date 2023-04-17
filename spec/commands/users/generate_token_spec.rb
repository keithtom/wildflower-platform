# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::GenerateToken, type: :command do
  let(:user) { create(:user) }

  subject { described_class.call(user) }

  describe "#call" do
    it "should succeed" do
      subject
      user.reload
      expect(user.authentication_token).to_not be_nil
      expect(user.authentication_token_created_at).to_not be_nil
    end
  end
end
