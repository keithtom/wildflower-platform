class School::InvitePartner < BaseService
  def initialize(person_params, school_relationship_params, school, inviter)
    @person_params = person_params
    @school_relationship_params = school_relationship_params
    @school = school
    @inviter = inviter
  end

  def run
    validate_school_status

    person = Person.find_or_create_by!(email: @person_params[:email])
    role = Person::TL
    if @school.status == School::Status::EMERGING
      person.update!(@person_params.merge(active: false))
      role = Person::ETL
    else
      person.update(@person_params.merge(active: true))
    end
    person.role_list.add(role)
    person.save!

    new_sr = person.school_relationships.empty?
    sr = SchoolRelationship.find_or_create_by!(school_id: @school.id, person_id: person.id)
    sr.role_list.add(role)
    sr.start_date = Date.today unless new_sr || person.is_onboarded
    sr.save!
    sr.update!(@school_relationship_params) if @school_relationship_params

    unless user = User.find_by(person_id: person.id)
      user = User.create!(email: person.email, person_id: person.id)
    end
    Users::GenerateToken.call(user)

    if @school.status == School::Status::EMERGING
      SSJMailer.invite_partner(user.id, @inviter.id, @school.ops_guides.first&.id).deliver_later
    else
      OpenTlMailer.invite_partner(user.id, @inviter.id, @school.name).deliver_later
    end
  end

  private

  def validate_school_status
    raise StandardError, 'School must have status' unless @school.status
  end
end
