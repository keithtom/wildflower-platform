require 'rails_helper'

describe V1::Advice::DecisionSerializer do
  let(:creator) { build(:person, external_identifier: "ppl331") }
  let(:stakeholder)  { build(:advice_stakeholder, external_identifier: "stk948")}
  let(:document)  { build(:document, external_identifier: "doc784")}
  let(:decision) { build(:advice_decision, external_identifier: "dec123") }

  subject { described_class.new(decision).as_json }

  before do
    decision.creator = creator
    decision.stakeholders = [stakeholder]
    decision.documents = [document]
  end

  it "should serialize properly" do
    expect(json_document['data']).to have_id("dec123")
    expect(json_document['data']).to have_type("decision")
    expect(json_document['data']).to have_jsonapi_attributes(:state, :title, :context, :proposal, :decideBy, :adviceBy, :role, :finalSummary, :createdAt, :updatedAt, :lastActivity)
    expect(json_document['data']).to have_relationships(:creator, :stakeholders, :documents)

    expect(json_document['data']).to have_relationship(:creator).with_data({'id' => 'ppl331', 'type' => 'person'})
    expect(json_document['data']).to have_relationship(:stakeholders).with_data([{'id' => 'stk948', 'type' => 'stakeholder'}])
    expect(json_document['data']).to have_relationship(:documents).with_data([{'id' => 'doc784', 'type' => 'document'}])
  end

  # add ability to do eager loading
  # no activities unless eager loaded
end
