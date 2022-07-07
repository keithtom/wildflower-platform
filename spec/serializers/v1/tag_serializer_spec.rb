require 'rails_helper'

describe V1::TagSerializer do
  let(:tag) { build(:tag) }

  subject { described_class.new(tag).as_json }

  it "should serialize properly" do
    # expect(json_document['data']).to have_id("pod123")
    expect(json_document['data']).to have_type("tag")
    expect(json_document['data']).to have_jsonapi_attributes(:name, :description)
  end
end
