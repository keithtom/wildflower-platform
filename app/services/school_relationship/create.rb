class SchoolRelationship::Create < BaseService
  def initialize(school_relationship_params, inviter)
    @school_relationship_params = school_relationship_params
    @inviter = inviter
    @person = nil
    @school = nil
  end

  def run
    @school = School.find_by!(external_identifier: @school_relationship_params.delete(:school_id))
    @person = Person.find_by!(external_identifier: @school_relationship_params.delete(:person_id))

    @school_relationship = SchoolRelationship.new(@school_relationship_params)
    @school_relationship.school = @school
    @school_relationship.person = @person
    @school_relationship.save!

    send_invite_email

    @school_relationship
  end

  def send_invite_email
    unless user = User.find_by(person_id: @person.id)
      user = User.create!(email: @person.email, person_id: @person.id)
    end
    Users::GenerateToken.call(user)

    SchoolMailer.add_partner(user.id, @school.name).deliver_later
  end
end
