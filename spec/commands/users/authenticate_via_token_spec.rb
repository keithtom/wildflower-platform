# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::AuthenticateViaToken, type: :command do
  let(:token) { Devise.friendly_token }
  let!(:user) { create(:user, authentication_token: token, authentication_token_at: 5.minutes.ago ) }

  subject { described_class.call(token) }

  describe "#call" do
    it "should succeed" do
      expect(subject).to be_truthy
      user.reload
      expect(user.authentication_token).to be_nil
      expect(user.authentication_token_at).to be_nil
    end

    context "when the token has expired" do
      before { user.update_column :authentication_token_at, 1.day.ago }

      it "should fail" do
        expect(subject).to be_falsey
        user.reload
        expect(user.authentication_token).to be_nil
        expect(user.authentication_token_at).to be_nil
      end
    end

    context "when the token is invalid" do
      before { user.update_column :authentication_token, "something else" }

      it "should fail" do
        expect(subject).to be_falsey
      end
    end
  end

end
