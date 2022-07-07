require 'rails_helper'

describe V1::SchoolRelationshipSerializer do
  let(:school_relationship) { build(:school_relationship, external_identifier: "sr444" ) }

  subject { described_class.new(school_relationship).as_json }

  it "should serialize properly" do
    expect(json_document['data']).to have_id("sr444")
    expect(json_document['data']).to have_type("schoolRelationship")
    expect(json_document['data']).to have_jsonapi_attributes(:name, :description, :startDate, :endDate)
  end
end
