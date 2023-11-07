class SSJ::InviteTeam < BaseService
  def initialize(user_params, ops_guide, regional_growth_leader)
    @ops_guide = ops_guide
    @ops_guide_user = User.find_by(person_id: @ops_guide.id)
    raise "Ops guide's user record not created for person_id: #{@ops_guide.external_identifier}" if @ops_guide_user.nil?
    @regional_growth_leader = regional_growth_leader
    rgl_user = User.find_by(person_id: @regional_growth_leader.id)
    raise "RGL's user record not created for person_id: #{@regional_growth_leader.external_identifier}" if rgl_user.nil?

    @user_params = user_params

    @team = nil
    @workflow_instance = nil
  end

  def run
    create_users_and_people
    create_workflow_instance
    create_team
    send_emails
    @team
  end

  private

  def create_users_and_people
    @user_params.each do |param|
      create_user_person(param[:email].downcase, param[:first_name], param[:last_name])
    end
  end

  def create_user_person(email, first_name, last_name)
    person = Person.create(email: email, first_name: first_name, last_name: last_name, active: false)
    user = User.create(email: email, person_id: person.id)
  end

  def create_workflow_instance
    workflow_definition = Workflow::Definition::Workflow.find_by!(name: "National, Independent Sensible Default")
    @workflow_instance = workflow_definition.instances.create!
    SSJ::InitializeWorkflowJob.perform_later(@workflow_instance.id)
  end

  def create_team 
    @team = SSJ::Team.create!(
      workflow: @workflow_instance, 
      ops_guide_id: @ops_guide.id, 
      regional_growth_lead_id: @regional_growth_leader.id
    )
    SSJ::TeamMember.create!(person: @ops_guide, ssj_team: @team, role: SSJ::TeamMember::OPS_GUIDE, status: SSJ::TeamMember::ACTIVE)
    SSJ::TeamMember.create!(person: @regional_growth_leader, ssj_team: @team, role: SSJ::TeamMember::RGL, status: SSJ::TeamMember::ACTIVE)
    @user_params.each do |param|
      person= Person.find_by email: param[:email].downcase
      SSJ::TeamMember.create!(person: person, ssj_team: @team, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
    end
  end

  def send_emails
    @user_params.each do |param|
      user = User.find_by email: param[:email].downcase
      Users::SendInviteEmail.call(user, @ops_guide_user)
    end
    # Users::SendOpsGuideInviteEmail.call(@ops_guide_user, @team)
  end
end