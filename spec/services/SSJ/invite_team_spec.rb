require 'rails_helper'

RSpec.describe SSJ::InviteTeam, type: :service do
  let(:ops_guide) { create(:person) }
  let(:regional_growth_leader) { create(:person) }
  let(:user_params) { [{ email: Faker::Internet.email, first_name: 'Test', last_name: 'One' }, { email: Faker::Internet.email, first_name: 'Test', last_name: 'Two' }] }

  before do
    create(:user, person_id: ops_guide.id)
    create(:user, person_id: regional_growth_leader.id)
    create(:workflow_definition_workflow)
  end

  describe '#run' do
    include ActiveJob::TestHelper

    it 'creates users, people, a workflow instance, a team, and sends emails' do
      perform_enqueued_jobs do
        expect { described_class.new(user_params, ops_guide, regional_growth_leader).run }.
        to change { User.count }.by(2).
        and change { Person.count }.by(2).
        and change { SSJ::Team.count }.by(1).
        and change { SSJ::TeamMember.count }.by(4).
        and change { Workflow::Instance::Workflow.count }.by(1).
        and change { ActionMailer::Base.deliveries.count }.by(2)
      end
    end

    it 'raises an error if the ops guide person record is not created' do
      User.find_by(person_id: ops_guide.id).destroy
      expect { described_class.new(user_params, ops_guide, regional_growth_leader).run }.to raise_error(RuntimeError, "Ops guide's user record not created for person_id: #{ops_guide.external_identifier}")
    end

    it 'raises an error if the RGL person record is not created' do
      User.find_by(person_id: regional_growth_leader.id).destroy
      expect { described_class.new(user_params, ops_guide, regional_growth_leader).run }.to raise_error(RuntimeError, "RGL's user record not created for person_id: #{regional_growth_leader.external_identifier}")
    end
  end
end