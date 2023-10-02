class SSJ::InvitePartner < BaseService
  def initialize(person_params, team, inviter)
    @person_params = person_params
    @team = team
    @inviter = inviter
  end

  def run
    person = Person.find_or_create_by!(email: @person_params[:email])
    person.update!(@person_params.merge(active: false))
    team_member = SSJ::TeamMember.find_or_create_by!(ssj_team_id: @team.id, person_id: person.id) do |team_member|
      team_member.role = SSJ::TeamMember::PARTNER
      team_member.status = SSJ::TeamMember::INVITED
    end
    
    unless user = User.find_by(person_id: person.id)
      user = User.create!(email: person.email, person_id: person.id)
    end
    Users::GenerateToken.call(user)

    SSJMailer.invite_partner(user, @inviter).deliver_later
  end
end
