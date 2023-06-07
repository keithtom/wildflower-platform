class TestController < ApplicationController
  def reset_fixtures
    ActiveRecord::Base.transaction do
      destroy_test_records
      create_test_user(params[:email])
    end
  end
  
  def invite_email_link
    user = create_test_user(params[:email])
    Users::GenerateToken.call(user)
    link = CGI.escape("/welcome/new-etl")
    invite_url = "/token?token=#{user.authentication_token}&redirect=#{link}"

    render json: { invite_url: invite_url }
  end

  private

  def destroy_test_records
    User.where("lower(email) like ?", "cypress_test%").where("created_at < ?", 1.days.ago).each do |user|
      person = user&.person
      user&.destroy! 
      if person
        person.address&.destroy!
        person.profile_image&.purge

        if ssj_team = person.ssj_team
          ssj_team.ops_guide_id = nil
          ssj_team.regional_growth_lead_id = nil
          ssj_team.save!

          ssj_team.team_members.each do |team_member|
            User.where(person_id: team_member.person_id).destroy_all
            team_member.person&.destroy!
            team_member.destroy!
          end
          ssj_team.destroy!
        end
      
        workflow_instance = ssj_team.workflow
        workflow_instance.processes.each do |process|
          process.steps.each do |step|
            step.assignments.each do |assignment|
              assignment.destroy!
            end
            step.destroy!
          end
          process.destroy!
        end
        workflow_instance.destroy!
      end
    end
  end

  def create_test_user(email)
    user = User.create!(email: email, password: 'password')
    person = Person.create!(image_url: 'https://en.gravatar.com/userimage/4310496/6924cffc6c2e516293c1e8b6e7533ab5.jpg')
    user.person = person
    user.save!
    Address.create!(addressable: person) if person.address.nil?
    
    ops_guide = FactoryBot.create(:person, role_list: "ops_guide")
    workflow_definition = Workflow::Definition::Workflow.find_by(name: "Basic Workflow")
    workflow_instance = SSJ::Initialize.run(workflow_definition)
    ssj_team = SSJ::Team.create!(workflow: workflow_instance, ops_guide_id: ops_guide.id)

    SSJ::TeamMember.create(person: ops_guide, ssj_team: ssj_team, role: SSJ::TeamMember::OPS_GUIDE, status: SSJ::TeamMember::ACTIVE)
    SSJ::TeamMember.create!(person_id: person.id, ssj_team_id: ssj_team.id, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)

    return user
  end
end