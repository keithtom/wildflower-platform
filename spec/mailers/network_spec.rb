require "rails_helper"

RSpec.describe NetworkMailer, type: :subjecter do

  describe ".invite" do
    let(:user) { build(:user, authentication_token: Devise.friendly_token) }
    let(:subject) { described_class.invite(user) }

    it "renders the headers" do
      expect(subject.subject).to eq("Welcome to the Wildflower Platform!")
      expect(subject.to).to eq([user.email])
      expect(subject.from).to eq(["platform@email.wildflowerschools.org"])
      expect(subject.reply_to).to eq(["support@wildflowerschools.org"])
    end

    it "renders the body" do
      expect(subject.body.encoded).to match("Wildflower Platform")
      expect(subject.body.encoded).to match(CGI.escape("/welcome/existing-tl"))
      expect(subject.body.encoded).to match(user.authentication_token)
    end
  end
end