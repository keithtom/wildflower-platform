require 'rails_helper'

describe V1::HubSerializer do
  let(:entrepreneur) { build(:person, external_identifier: "abc456" ) }
  let(:hub) { build(:hub, entrepreneur: entrepreneur, external_identifier: "hub123") }

  subject { described_class.new(hub).as_json }

  it "should serialize properly" do
    expect(json_document['data']).to have_id("hub123")
    expect(json_document['data']).to have_type("hub")
    expect(json_document['data']).to have_jsonapi_attributes(:name)
    expect(json_document['data']).to have_relationships(:entrepreneur)

    expect(json_document['data']).to have_relationship(:entrepreneur).with_data({'id' => 'abc456', 'type' => 'person'})
  end
end
