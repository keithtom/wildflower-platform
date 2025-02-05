class SSJ::Abandon < BaseService
  def initialize(team, school = nil)
    @team = team
    @school = school || School.find_by(name: team.temp_name)
  end

  def run
    @team.team_members.each do |member|
      if member.status == 'active'
        member.status = 'inactive'
        member.save!
      end
    end

    if @school
      @school.status = 'Abandoned'
      @school.save
      @school.school_relationships.each do |sr|
        sr.end_date = Date.today
        sr.save
      end
    end
  end
end
