# frozen_string_literal: true

class School::RemovePartner < BaseService
  def initialize(partner, school)
    @partner = partner
    @school = school
  end

  def run
    sr = SchoolRelationship.find_by(school_id: @school.id, person_id: @partner.id)
    raise StandardError, "Partner #{@partner.email} not associated to school #{@school.name}" if sr.nil?

    sr.end_date = Date.today
    sr.save!

    # Is this person associated to any other schools?
    return if @partner.school_relationships.active.any?

    # do not show in directory
    @partner.active = false
    @partner.save!

    # delete user id and password
    user = User.find_by(person_id: @partner.id)
    user&.destroy!
  end
end
