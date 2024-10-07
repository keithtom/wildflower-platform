class TestController < ApplicationController
  def reset_fixtures
    ActiveRecord::Base.transaction do
      create_test_user_with_ssj(params[:email], nil, params[:is_onboarded])
    end
  end

  def reset_partner_fixtures
    ActiveRecord::Base.transaction do
      ssj_team = nil
      params[:emails].each_with_index do |email, index|
        user = create_test_user_with_ssj(email, ssj_team)
        ssj_team = user.person.ssj_team if index == 0
      end
    end
  end

  def reset_network_fixtures
    ActiveRecord::Base.transaction do
      user = create_test_user(params[:email], params[:is_onboarded])
      user.person.role_list.add(Person::TL)
      user.person.save
      create_school(user.person)
    end
  end

  def reset_rollout_workflow_fixture
    ActiveRecord::Base.transaction do
      name = 'Basic Workflow for Cypress Tests'
      delete_workflow(name)
      workflow_definition = Workflow::Definition::Workflow::CreateDummy.run(name)
      wf_instance = workflow_definition.instances.create!
      Workflow::InitializeWorkflowJob.perform_later(wf_instance.id)
    end
  end

  def invite_email_link
    user = create_test_user_with_ssj(params[:email], nil, params[:is_onboarded])
    Users::GenerateToken.call(user)
    invite_url = "/token?token=#{user.authentication_token}"

    render json: { invite_url: }
  end

  def network_invite_email_link
    person = Person.create!(email: params[:email], is_onboarded: params[:is_onboarded])
    user = User.create!(email: params[:email], person_id: person.id)
    Users::GenerateToken.call(user)
    invite_url = "/token?token=#{user.authentication_token}"

    render json: { invite_url: }
  end

  private

  def create_test_user_with_ssj(email, ssj_team = nil, is_onboarded = false)
    user = create_test_user(email, is_onboarded)
    user.person.role_list.add(Person::ETL)
    user.person.save!

    if ssj_team.nil?
      ops_guide = FactoryBot.create(:person, role_list: 'ops_guide')
      workflow_definition = Workflow::Definition::Workflow.find_by(name: 'Basic Workflow')
      workflow_instance = workflow_definition.instances.create!
      Workflow::Initialize.run(workflow_instance.id)
      ssj_team = SSJ::Team.create!(workflow: workflow_instance, ops_guide_id: ops_guide.id)
      SSJ::TeamMember.create(person: ops_guide, ssj_team:, role: SSJ::TeamMember::OPS_GUIDE,
                             status: SSJ::TeamMember::ACTIVE)
    end

    SSJ::TeamMember.create!(person_id: user.person_id, ssj_team_id: ssj_team.id, role: SSJ::TeamMember::PARTNER,
                            status: SSJ::TeamMember::ACTIVE)

    user
  end

  def create_test_user(email, is_onboarded = false)
    person = Person.create!(image_url:, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name,
                            is_onboarded:, email:)
    user = User.create!(email:, password: 'password', person_id: person.id)
    Address.create!(addressable: person) if person.address.nil?

    user
  end

  def create_school(person)
    school = School.create!(name: 'Cypress Test School')
    school.address = Address.create!(addressable: school, state: 'CA', city: 'San Francisco', line1: '123 Main St',
                                     zip: '94105')
    school.school_relationships.create!(person:)
    school.save!
    school
  end

  def image_url
    [
      'https://en.gravatar.com/userimage/4310496/6924cffc6c2e516293c1e8b6e7533ab5.jpg',
      'https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50',
      'https://ca.slack-edge.com/T1BCRBEKF-U044095NSKW-gb71eb8af435-512',
      'https://ca.slack-edge.com/T1BCRBEKF-U6YFWTW67-8c867b8d8fff-512',
      'https://ca.slack-edge.com/T1BCRBEKF-U0431E2ANE6-a196fd3638aa-512',
      'https://ca.slack-edge.com/T1BCRBEKF-UC1RV1LQ5-eb11f16c81c0-192'
    ].sample
  end

  def delete_workflow(name)
    Workflow::Definition::Workflow.where(name:).each do |workflow|
      workflow.processes.each do |process|
        process.steps.each do |step|
          step.decision_options.each do |decision_option|
            decision_option.destroy!
          end
          step.instances.destroy_all
          step.destroy!
        end
        process.instances.destroy_all
        process.destroy!
      end
      workflow.instances.destroy_all
      workflow.destroy!
    end
  end
end
