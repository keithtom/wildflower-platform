require 'rails_helper'

describe V1::Advice::StakeholderSerializer do

  let(:stakeholder) { create(:advice_stakeholder, external_identifier: "stk396") }

  before do
    stakeholder.decision.external_identifier = "dec941"
    create(:advice_record, stakeholder: stakeholder, decision: stakeholder.decision, status: "Hello")
  end

  subject { described_class.new(stakeholder).as_json }

  it "should serialize properly" do
    expect(json_document['data']).to have_id("stk396")
    expect(json_document['data']).to have_type("stakeholder")
    expect(json_document['data']).to have_jsonapi_attributes(:name, :email, :phone, :calendarUrl, :roles, :subroles, :status, :activities, :lastActivity)
    expect(json_document['data']).to have_relationships(:decision)

    expect(json_document['data']).to have_relationship(:decision).with_data({'id' => 'dec941', 'type' => 'decision'})
  end

  # add ability to do eager loading
  # no activities unless eager loaded

  describe "when activities are included" do    
  end
end
