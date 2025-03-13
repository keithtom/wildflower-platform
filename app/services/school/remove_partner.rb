# frozen_string_literal: true

class School::RemovePartner < BaseService
  def initialize(partner, school, end_date = nil)
    @partner = partner
    @school = school
    @end_date = end_date
  end

  def run
    sr = SchoolRelationship.find_by(school_id: @school.id, person_id: @partner.id)
    raise StandardError, "Partner #{@partner.email} not associated to school #{@school.name}" if sr.nil?

    sr.end_date = @end_date || Date.today
    sr.save!

    # destroy all incomplete assignments
    @partner.assignments.for_workflow(@school.workflows.pluck(:id)).incomplete.destroy_all

    # Is this person associated to any other schools?
    return if @partner.school_relationships.active.any?

    @partner.active = false
    @partner.end_date = @end_date || Date.today
    @partner.save!

    # delete user id and password
    user = User.find_by(person_id: @partner.id)
    user&.destroy!
  end
end
