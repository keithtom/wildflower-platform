class SSJ::AddPartner < BaseService
  def initialize(person_params, team)
    @person_params = person_params
    @team = team
  end

  def run
    person = Person.find_or_create_by!(email: @person_params[:email])
    person.update!(@person_params)
    @team.people << person
    @team.save!

    unless user = User.find_by(person_id: person.id)
      user = User.create!(email: person.email, person_id: person.id)
      Users::GenerateToken.run(user)
    end

    PartnerMailer.invite(user)
  end
end
