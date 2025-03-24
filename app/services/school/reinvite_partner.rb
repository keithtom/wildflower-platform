# frozen_string_literal: true

class School::ReinvitePartner < BaseService
  def initialize(person, school, inviter)
    @person = person
    @school = school
    @inviter = inviter
  end

  def run
    validate_school_status

    unless user = User.find_by(person_id: @person.id)
      user = User.create!(email: @person.email, person_id: @person.id)
    end
    Users::GenerateToken.call(user)

    if @school.status == School::Status::EMERGING
      SSJMailer.invite_partner(user.id, @inviter.id, @school.ops_guides.first&.id).deliver_later
    else
      OpenTlMailer.invite_partner(user.id, @inviter.id, @school.name).deliver_later
    end
  end

  def validate_school_status
    raise StandardError, 'School must have status' unless @school.status
  end
end
