require 'rails_helper'

describe V1::AddressSerializer do
  let(:address) { build(:address, external_identifier: "add123" ) }

  subject { described_class.new(address).as_json }

  it "should serialize properly" do
    expect(json_document['data']).to have_id("add123")
    expect(json_document['data']).to have_type("address")
    expect(json_document['data']).to have_jsonapi_attributes(:line1, :city, :state, :zip)
  end
end
