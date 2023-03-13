class SSJ::InvitePartner < BaseService
  def initialize(person_params, team, inviter)
    @person_params = person_params
    @team = team
    @inviter = inviter
  end

  def run
    person = Person.find_or_create_by!(email: @person_params[:email])
    SSJ::TeamMember.create!(ssj_team: @team, person: person, current: true, role: "partner")

    unless user = User.find_by(person_id: person.id)
      user = User.create!(email: person.email, person_id: person.id)
    end
    Users::GenerateToken.call(user)

    PartnerMailer.invite(user, @inviter)
  end
end
