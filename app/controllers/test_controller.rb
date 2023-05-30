class TestController < ApplicationController
  def reset_fixtures
    user = User.find_by(email: 'cypress_test@test.com')

    ActiveRecord::Base.transaction do
      # delete everything associated to this user
      person = user.person
      user.destroy!
      if person
        person.address&.destroy!
        person.profile_image&.purge

        ssj_team = person.ssj_team
        ssj_team.ops_guide = nil
        ssj_team.regional_growth_lead_id = nil
        ssj_team.save!

        ssj_team.team_members.each do |team_member|
          User.where(person_id: team_member.person_id).destroy_all
          team_member.person&.destroy!
          team_member.destroy!
        end
        ssj_team.destroy!
      
        workflow_instance = ssj_team.workflow
        workflow_instance.processes.each do |process|
          process.steps.each do |step|
            step.destroy!
          end
          process.destroy!
        end
        workflow_instance.destroy!

        # create clean user, person and workflow
        user = User.create!(email: 'cypress_test@test.com', password: 'password')
        person = Person.create!
        user.person = person
        user.save!
        Address.create!(addressable: person) if person.address.nil?
        
        ops_guide = FactoryBot.create(:person, role_list: "ops_guide")
        workflow_definition = Workflow::Definition::Workflow.find_by(name: "Basic Workflow")
        workflow_instance = SSJ::Initialize.run(workflow_definition)
        ssj_team = SSJ::Team.create!(workflow: workflow_instance, ops_guide_id: ops_guide.id)

        SSJ::TeamMember.create(person: ops_guide, ssj_team: ssj_team, role: SSJ::TeamMember::OPS_GUIDE, status: SSJ::TeamMember::ACTIVE)
        SSJ::TeamMember.create!(person_id: person.id, ssj_team_id: ssj_team.id, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
      end
    end
  end
end