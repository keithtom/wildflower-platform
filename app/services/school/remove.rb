class School::Remove < BaseService
  def initialize(school)
    @school = school
  end

  def run
    @school.school_relationships.where(end_date: nil).each do |sr|
      School::RemovePartner.run(sr.person, @school, Time.zone.today)
    end

    # TODO: Should workflows be updated with a flag that they've been abandoned as well?
    @school.affiliated = false
    @school.directory_visible = false
    @school.status = School::Status::ABANDONED
    @school.save!
  end
end
