require 'rails_helper'

describe V1::SchoolSerializer do
  let(:pod) { build(:pod, external_identifier: "pod555") }
  let(:school_relationship) { build(:school_relationship, external_identifier: "sr699") }
  let(:person) { build(:person, external_identifier: "ppl345") }
  let(:address) { build(:address, external_identifier: "addr22") }
  let(:school) { build(:school, external_identifier: "sch333") }

  subject { described_class.new(school).as_json }

  before do
    school.pod = pod
    school.people = [person]
    school.school_relationships = [school_relationship]
    school.address = address
  end

  it "should serialize properly" do
    expect(json_document['data']).to have_id("sch333")
    expect(json_document['data']).to have_type("school")
    expect(json_document['data']).to have_jsonapi_attributes(:name, :website, :phone, :email)
    expect(json_document['data']).to have_relationships(:pod, :schoolRelationships, :people, :address)

    expect(json_document['data']).to have_relationship(:pod).with_data({'id' => 'pod555', 'type' => 'pod'})
    expect(json_document['data']).to have_relationship(:schoolRelationships).with_data([{'id' => 'sr699', 'type' => 'schoolRelationship'}])
    expect(json_document['data']).to have_relationship(:people).with_data([{'id' => 'ppl345', 'type' => 'person'}])
    expect(json_document['data']).to have_relationship(:address).with_data({'id' => 'addr22', 'type' => 'address'})
  end
end
