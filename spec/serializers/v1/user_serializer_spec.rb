
require 'rails_helper'

describe V1::UserSerializer do
  let(:user) { build(:user) }
  let(:ssj_team) { build(:ssj_team) }

  before do
    ssj_team.people.where(
  end

  subject { described_class.new(user).as_json }

  it "should serialize properly" do
    expect(json_document['data']).to have_jsonapi_attributes(:title, :position, :stepsCount, :completedStepsCount, :description, :phase, :status, :categories, :stepsAssignedCount)
    expect(json_document['data']).to have_relationships(:steps, :workflow)
  end
end
