require "rails_helper"

RSpec.describe NetworkMailer, type: :subjecter do

  describe "invite" do
    let(:user) { build(:user, authentication_token: Devise.friendly_token) }
    let(:subject) { described_class.invite(user) }

    it "renders the headers" do
      expect(subject.subject).to eq("Welcome to #{ENV['APP_NAME']}!")
      expect(subject.to).to eq([user.email])
      expect(subject.from).to eq(["platform@email.wildflowerschools.org"])
      expect(subject.reply_to).to eq(["support@wildflowerschools.org"])
    end

    it "renders the body" do
      expect(subject.body.encoded).to match(ENV['APP_NAME'])
      expect(subject.body.encoded).to match(user.authentication_token)
    end
  end

  describe "remind_login" do
    let(:user) { build(:user, authentication_token: Devise.friendly_token) }
    let(:subject) { described_class.remind_login(user) }

    it "renders the headers" do
      expect(subject.subject).to eq("5 min request: Vote on the next #{ENV['APP_NAME']} features we should build!")
      expect(subject.to).to eq([user.email])
      expect(subject.from).to eq(["platform@email.wildflowerschools.org"])
      expect(subject.reply_to).to eq(["support@wildflowerschools.org"])
    end

    it "renders the body" do
      expect(subject.body.encoded).to match(ENV['APP_NAME'])
      expect(subject.body.encoded).to match(user.authentication_token)
    end
  end
end
