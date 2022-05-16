require 'rails_helper'

RSpec.describe Advice::Stakeholder, type: :model do
  describe "when the stakeholder is an internal person" do
    let(:person) { build(:person) }
    subject { build(:advice_stakeholder, person: person)}
    its(:name) { is_expected.to be == person.name }
    its(:email) { is_expected.to be == person.email }
    its(:phone) { is_expected.to be == person.phone }
    its(:calendar_url) { is_expected.to include("calendar.google.com") }
    its(:calendar_url) { is_expected.to include("add=#{person.email}") }
    its(:roles) { is_expected.to be == person.roles }
    its(:subroles) { is_expected.to be == person.subroles }
  end

  describe "when the stakeholder is an external person" do
    subject { build(:external_advice_stakeholder,
      external_name: "Keith",
      external_email: "keith.tom@gmail.com",
      external_phone: "123-456-7890",
      external_calendar_url: "https://calendly.com/keith-tom",
      external_roles: "Software Developer, Product Manager",
      external_subroles: "Requirements Gathering, Development, QA, Dev Ops, Sprint Manager, Architect"
     )
    }

    its(:person) { is_expected.to be_nil }
    its(:name) { is_expected.to be == "Keith" }
    its(:email) { is_expected.to be == "keith.tom@gmail.com" }
    its(:phone) { is_expected.to be == "123-456-7890" }
    its(:calendar_url) { is_expected.to be == "https://calendly.com/keith-tom" }
    its(:roles) { is_expected.to contain_exactly "Software Developer", "Product Manager" }
    its(:subroles) { is_expected.to contain_exactly "Requirements Gathering", "Development", "QA", "Dev Ops", "Sprint Manager", "Architect" }
  end
end
