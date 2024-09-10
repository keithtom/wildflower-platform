class School::InvitePartner < BaseService
  def initialize(person_params, school_relationship_params, school, inviter)
    @person_params = person_params
    @school_relationship_params = school_relationship_params
    @school = school
    @inviter = inviter
  end

  def run
    person = Person.find_or_create_by!(email: @person_params[:email].downcase)
    person.update(@person_params.merge(active: true))
    person.role_list.add(Person::TL)
    person.save!

    sr = SchoolRelationship.find_or_create_by!(school_id: @school.id, person_id: person.id)
    sr.update!(@school_relationship_params)

    unless user = User.find_by(person_id: person.id)
      user = User.create!(email: person.email, person_id: person.id)
    end
    Users::GenerateToken.call(user)

    OpenTlMailer.invite_partner(user.id, @inviter.id).deliver_later
  end
end
