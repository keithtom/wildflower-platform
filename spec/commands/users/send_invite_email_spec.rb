# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::SendInviteEmail, type: :command do
  let(:user) { create(:user) }

  subject { described_class.call(user) }

  describe "#call" do
    it "should succeed" do
      expect { subject }.to have_enqueued_job.on_queue('mailers').with('UserMailer', 'invite', 'deliver_now', params: { user: user }, args: [])
      user.reload
      expect(user.authentication_token).to_not be_nil
      expect(user.authentication_token_at).to_not be_nil
    end
  end
end
