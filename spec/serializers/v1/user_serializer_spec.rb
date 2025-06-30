require 'rails_helper'

describe V1::UserSerializer do
  subject { described_class.new(user, { include: ['person', 'person.address'] }).as_json }

  let(:user) { build(:user) }
  let(:ssj_team) { build(:ssj_team) }
  let!(:workflow) { create(:workflow_instance_workflow) }
  let!(:school) { create(:school, workflow_id: workflow.id, status: School::Status::OPEN) }
  let!(:school_relationship) { create(:school_relationship, person_id: person.id, school_id: school.id) }
  let(:person) { create(:person) }

  before do
    SSJ::TeamMember.create(person:, ssj_team:, status: SSJ::TeamMember::ACTIVE,
                           role: SSJ::TeamMember::PARTNER)
    person.save!
    address = create(:address, addressable: person)
    user.person = person
    user.save!
  end

  it 'serializes properly' do
    expect(json_document['data']).to have_jsonapi_attributes(:email, :firstName, :lastName, :imageUrl, :ssj)
    expect(json_document['data']).to have_relationships(:person)
    expect(json_document['data']['attributes']['ssj']['currentPhase']).to eq('visioning')
    expect(json_document['data']['attributes']['schools']).to eq([
                                                                   {
                                                                     'id' => school_relationship.school.external_identifier,
                                                                     'affiliated' => true,
                                                                     'end_date' => school_relationship.end_date.to_s('%yyyy-mm-dd'),
                                                                     'name' => school.name,
                                                                     'role_list' => school_relationship.role_list,
                                                                     'start_date' => school_relationship.start_date.to_s('yyyy-mm-dd'),
                                                                     'workflowId' => workflow.external_identifier,
                                                                     'workflowIds' => []
                                                                   }
                                                                 ])
    expect(json_document['included']).to include(have_type('address').and(have_attribute(:city)))
  end
end
