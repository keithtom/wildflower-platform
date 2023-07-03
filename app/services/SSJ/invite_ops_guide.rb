class SSJ::InviteOpsGuide < BaseService
  def initialize(user, team)
    @user = user
    @team = team
  end

  def run
    person = Person.find_or_create_by!(email: @person_params[:email])
    person.update!(@person_params)
    team_member = SSJ::TeamMember.find_or_create_by!(ssj_team_id: @team.id, person_id: person.id) do |team_member|
      team_member.role = SSJ::TeamMember::OPS_GUIDE
      team_member.status = SSJ::TeamMember::ACTIVE
    end
    
    unless user = User.find_by(person_id: person.id)
      user = User.create!(email: person.email, person_id: person.id)
    end
    Users::GenerateToken.call(user)

    SSJMailer.invite_ops_guide(@user, @team).deliver_later
  end
end
