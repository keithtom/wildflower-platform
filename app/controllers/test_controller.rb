class TestController < ApplicationController
  def reset_fixtures
    ActiveRecord::Base.transaction do
      destroy_test_records
      create_test_user(params[:email])
    end
  end
  
  def reset_partner_fixtures
    ActiveRecord::Base.transaction do
      destroy_test_records
      ssj_team = nil
      params[:emails].each_with_index do |email, index|
        user = create_test_user(email, ssj_team)
        if index == 0 
          ssj_team = user.person.ssj_team
        end
      end
    end
  end
  
  def invite_email_link
    user = create_test_user(params[:email], nil, params[:is_onboarded])
    Users::GenerateToken.call(user)
    link = helpers.redirect_path(user)
    invite_url = "/token?token=#{user.authentication_token}&redirect=#{link}"

    render json: { invite_url: invite_url }
  end

  def network_invite_email_link
    person = Person.create!(email: params[:email], is_onboarded: params[:is_onboarded])
    user = User.create!(email: params[:email], person_id: person.id)
    Users::GenerateToken.call(user)
    link = helpers.redirect_path(user)
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
  end

  def create_test_user(email, ssj_team = nil, is_onboarded = false)
    person = Person.create!(image_url: image_url, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, is_onboarded: is_onboarded)
    user = User.create!(email: email, password: 'password', person_id: person.id)
    Address.create!(addressable: person) if person.address.nil?
    
    if ssj_team.nil?
      ops_guide = FactoryBot.create(:person, role_list: "ops_guide")
      workflow_definition = Workflow::Definition::Workflow.find_by(name: "Basic Workflow")
      workflow_instance = SSJ::Initialize.run(workflow_definition)
      ssj_team = SSJ::Team.create!(workflow: workflow_instance, ops_guide_id: ops_guide.id)
      SSJ::TeamMember.create(person: ops_guide, ssj_team: ssj_team, role: SSJ::TeamMember::OPS_GUIDE, status: SSJ::TeamMember::ACTIVE)
    end

    SSJ::TeamMember.create!(person_id: person.id, ssj_team_id: ssj_team.id, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)

    return user
  end

  def image_url
    [
        'https://en.gravatar.com/userimage/4310496/6924cffc6c2e516293c1e8b6e7533ab5.jpg',
        'https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50',
        'https://ca.slack-edge.com/T1BCRBEKF-U044095NSKW-gb71eb8af435-512',
        'https://ca.slack-edge.com/T1BCRBEKF-U6YFWTW67-8c867b8d8fff-512',
        'https://ca.slack-edge.com/T1BCRBEKF-U0431E2ANE6-a196fd3638aa-512',
        'https://ca.slack-edge.com/T1BCRBEKF-UC1RV1LQ5-eb11f16c81c0-192',
    ].sample
  end
end