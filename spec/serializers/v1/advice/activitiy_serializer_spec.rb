require 'rails_helper'

describe V1::Advice::ActivitySerializer do
  let(:activity) { Advice::Activity.new(id: "n/a", type: "event", person: { name: "Joe" }, title: "The title", content: "The content", updated_at: Time.now) }

  subject { described_class.new(activity).as_json }

  it "should serialize properly" do
    expect(json_document['data']).to have_id("n/a")
    expect(json_document['data']).to have_type("activity")
    expect(json_document['data']).to have_jsonapi_attributes(:type, :person, :title, :content)
  end
end
