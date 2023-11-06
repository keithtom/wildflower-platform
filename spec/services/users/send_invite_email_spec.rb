# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::SendInviteEmail, type: :command do
  let(:user) { create(:user) }
  let(:ops_guide) { create(:user) }

  subject { described_class.call(user, ops_guide) }

  describe "#call" do
    it "should succeed" do
      expect { subject }.to have_enqueued_job.on_queue('mailers').with('SSJMailer', 'invite', 'deliver_now', args: [user.id, ops_guide.id])
      user.reload
      expect(user.authentication_token).to_not be_nil
      expect(user.authentication_token_created_at).to_not be_nil
    end
  end
end
