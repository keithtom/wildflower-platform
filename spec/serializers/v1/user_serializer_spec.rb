
require 'rails_helper'

describe V1::UserSerializer do
  let(:user) { build(:user) }
  let(:ssj_team) { build(:ssj_team) }
  let!(:workflow) { create(:workflow_instance_workflow) }
  let!(:school) { create(:school, workflow_id: workflow.id) }

  before do
    person = build(:person)
    SSJ::TeamMember.create(person: person, ssj_team: ssj_team, status: SSJ::TeamMember::ACTIVE, role: SSJ::TeamMember::PARTNER)      
    person = ssj_team.partners.first
    person.hub = build(:hub)
    person.save!
    address = create(:address, addressable: person)
    user.person = person
    user.save!
  
    create(:school_relationship, person_id: person.id, school_id: school.id)
  end

  subject { described_class.new(user, {include: ['person', 'person.address']}).as_json }

  it "should serialize properly" do
    expect(json_document['data']).to have_jsonapi_attributes(:email, :firstName, :lastName, :imageUrl, :hub, :ssj)
    expect(json_document['data']).to have_relationships(:person)
    expect(json_document['data']['attributes']['ssj']['opsGuide']['data']).to have_id(ssj_team.ops_guide.external_identifier)
    expect(json_document['data']['attributes']['ssj']['regionalGrowthLead']['data']).to have_id(ssj_team.regional_growth_lead.external_identifier)
    expect(json_document['data']['attributes']['ssj']['currentPhase']).to eq('visioning')
    expect(json_document['data']['attributes']['schools']).to eq([{'name' => school.name, 'workflowId' => workflow.external_identifier}])
    expect(json_document['included']).to include(have_type('address').and have_attribute(:city))
  end
end
