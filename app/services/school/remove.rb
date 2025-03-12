class School::Remove < BaseService
  def initialize(school)
    @school = school
  end

  def run
    @school.school_relationships.where(end_date: nil).each do |sr|
      School::RemovePartner.run(sr.person, @school, Time.zone.today)
    end

    @school.affiliated = false
    @school.directory_visible = false
    @school.save!
  end
end
