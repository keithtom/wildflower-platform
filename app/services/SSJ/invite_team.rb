class SSJ::InviteTeam < BaseService
  def initialize(user_params, ops_guide, regional_growth_leader)
    @ops_guide = ops_guide
    @ops_guide_user = User.find_by(person_id: @ops_guide.id)
    raise "Ops guide's user record not created for person_id: #{@ops_guide.external_identifier}" if @ops_guide_user.nil?

    @regional_growth_leader = regional_growth_leader
    rgl_user = User.find_by(person_id: @regional_growth_leader.id)
    raise "RGL's user record not created for person_id: #{@regional_growth_leader.external_identifier}" if rgl_user.nil?

    @user_params = user_params
    @users = []

    @team = nil
    @workflow_instance = nil
  end

  def run
    create_users_and_people
    create_workflow_instance
    create_team
    create_school
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
    person = Person.find_or_create_by!(email:)
    person.first_name ||= first_name
    person.last_name ||= last_name
    person.active ||= false
    person.role_list.add(Person::ETL)
    person.save!

    # people sometimes have different user emails vs person email
    @users << (User.find_by(person_id: person.id) || User.create!(email: person.email, person_id: person.id))
  end

  def create_workflow_instance
    workflow_definition = Workflow::Definition::Workflow.latest_versions.where.not(published_at: nil).find_by!(name: 'National, Independent Sensible Default')
    @workflow_instance = workflow_definition.instances.create!
    Workflow::InitializeWorkflowJob.perform_later(@workflow_instance.id)
  end

  def create_team
    @team = SSJ::Team.create!(
      workflow: @workflow_instance,
      ops_guide_id: @ops_guide.id,
      regional_growth_lead_id: @regional_growth_leader.id
    )
    SSJ::TeamMember.create!(person: @ops_guide, ssj_team: @team, role: SSJ::TeamMember::OPS_GUIDE,
                            status: SSJ::TeamMember::ACTIVE)
    SSJ::TeamMember.create!(person: @regional_growth_leader, ssj_team: @team, role: SSJ::TeamMember::RGL,
                            status: SSJ::TeamMember::ACTIVE)
    @user_params.each do |param|
      person = Person.find_by email: param[:email].downcase
      SSJ::TeamMember.create!(person:, ssj_team: @team, role: SSJ::TeamMember::PARTNER,
                              status: SSJ::TeamMember::ACTIVE)
    end
    @team.temp_name = @team.build_temp_name
    @team.save!
  end

  def create_school
    school = School.create!(name: @team.temp_name, affiliated: false)
    @team.partner_members.each do |member|
      SchoolRelationship.create!(school_id: school.id, person_id: member.person_id)
    end
  end

  def send_emails
    @users.each do |user|
      Users::SendInviteEmail.call(user, @ops_guide_user)
    end
    # Users::SendOpsGuideInviteEmail.call(@ops_guide_user, @team)
  end
end
