require 'rails_helper'

describe V1::DocumentSerializer do
  let(:document) { build(:document, external_identifier: "doc123" ) }

  subject { described_class.new(document).as_json }

  it "should serialize properly" do
    expect(json_document['data']).to have_id("doc123")
    expect(json_document['data']).to have_type("document")
    expect(json_document['data']).to have_jsonapi_attributes(:inheritanceType, :title, :link)
  end
end
