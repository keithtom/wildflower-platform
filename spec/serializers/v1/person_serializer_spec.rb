require 'rails_helper'

describe V1::PersonSerializer do
  let(:address) { build(:address, external_identifier: "add123") }
  let(:school) { build(:school, external_identifier: "sch123") }
  let(:school_relationship) { build(:school_relationship, external_identifier: "sr123") }
  let(:person) { build(:person, address: address, external_identifier: "per456") }

  subject { described_class.new(person).as_json }

  before do
    person.schools = [school]
    person.school_relationships = [school_relationship]
  end

  it "should serialize properly" do
    expect(json_document['data']).to have_id("per456")
    expect(json_document['data']).to have_type('person')
    expect(json_document['data']).to have_jsonapi_attributes(:email, :roleList)
    expect(json_document['data']).to have_relationships(:address, :schools, :schoolRelationships)

    expect(json_document['data']).to have_relationship(:address).with_data({'id' => 'add123', 'type' => 'address'})
    expect(json_document['data']).to have_relationship(:schools).with_data([{'id' => 'sch123', 'type' => 'school'}])
    expect(json_document['data']).to have_relationship(:schoolRelationships).with_data([{'id' => 'sr123', 'type' => 'schoolRelationship'}])
  end
end
