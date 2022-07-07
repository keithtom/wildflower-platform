require 'rails_helper'

describe V1::PodSerializer do
  let(:primary_contact) { build(:person, external_identifier: "def789" ) }
  let(:hub) { build(:hub, external_identifier: "hub456" ) }
  let(:pod) { build(:pod, external_identifier: "pod123", hub: hub, primary_contact: primary_contact) }

  subject { described_class.new(pod).as_json }

  it "should serialize properly" do
    expect(json_document['data']).to have_id("pod123")
    expect(json_document['data']).to have_type("pod")
    expect(json_document['data']).to have_jsonapi_attributes(:name)
    expect(json_document['data']).to have_relationships(:hub, :primaryContact)

    expect(json_document['data']).to have_relationship(:hub).with_data({'id' => 'hub456', 'type' => 'hub'})
    expect(json_document['data']).to have_relationship(:primaryContact).with_data({'id' => 'def789', 'type' => 'person'})
  end
end
