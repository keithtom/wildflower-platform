class SSJ::InviteUser < BaseService
  def initialize(user, ops_guide_email)
    @user = user
    @ops_guide_email = ops_guide_email
    @workflow_instance = nil
    @ops_guide = nil
    @team = nil
  end

  def run
    create_person if @user.person.nil?
    create_workflow_instance
    create_ssj_team if @user.person.ssj_team.nil?
    Users::SendInviteEmail.call(@user)
    Users::SendOpsGuideInviteEmail.call(@ops_guide, @team)
  end

  def create_person
    @user.person = Person.create(email: @email, active: false)
    @user.save!
  end

  def create_ssj_team
    @ops_guide = User.find_by!(email: @ops_guide_email)
    @team = SSJ::Team.create!(workflow: @workflow_instance, ops_guide_id: ops_guide.person.id)
    SSJ::TeamMember.create!(person: @user.reload.person, ssj_team: team, role: SSJ::TeamMember::PARTNER, status: SSJ::TeamMember::ACTIVE)
    SSJ::TeamMember.create!(person: ops_guide.person, ssj_team: team, role: SSJ::TeamMember::OPS_GUIDE, status: SSJ::TeamMember::ACTIVE)
  end

  def create_workflow_instance
    workflow_definition = Workflow::Definition::Workflow.latest_versions.where.not(published_at: nil).find_by!(name: "National, Independent Sensible Default")
    @workflow_instance = workflow_definition.instances.create!
    Workflow::Initialize.run(workflow_instance.id)
    if @user.person.ssj_team
      @user.person.ssj_team.workflow = @workflow_instance
      @user.person.ssj_team.save!
    end
  end
end
