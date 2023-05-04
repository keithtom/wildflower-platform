
require 'rails_helper'

describe V1::UserSerializer do
  let(:user) { build(:user) }
  let(:ssj_team) { build(:ssj_team) }

  before do
    person = build(:person)
    SSJ::TeamMember.create(person: person, ssj_team: ssj_team, status: SSJ::TeamMember::ACTIVE, role: SSJ::TeamMember::PARTNER)      
    person = ssj_team.partners.first
    person.hub = build(:hub)
    person.save!
    user.person = person
    user.save!
  end

  subject { described_class.new(user).as_json }

  it "should serialize properly" do
    expect(json_document['data']).to have_jsonapi_attributes(:email, :firstName, :lastName, :imageUrl, :hub, :ssj)
    expect(json_document['data']).to have_relationships(:person)
    expect(json_document['data']['attributes']['ssj']['opsGuide']['data']).to have_id(ssj_team.ops_guide.external_identifier)
    expect(json_document['data']['attributes']['ssj']['regionalGrowthLead']['data']).to have_id(ssj_team.regional_growth_lead.external_identifier)
    expect(json_document['data']['attributes']['ssj']['currentPhase']).to eq('visioning')
  end
end
