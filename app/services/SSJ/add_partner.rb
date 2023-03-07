class SSJ::AddPartner < BaseService
  def initialize(email, team)
    @email = email
    @team = team
  end

  def run
    person = Person.create!(email: @email)
    user = User.create!(email: @email, person: person)
    # TODO: set role on person?

    puts "TEAM ID: #{@team.id}"
    @team.people << user.person
    @team.save!

    UserMailer.invite(user)
  end

end
