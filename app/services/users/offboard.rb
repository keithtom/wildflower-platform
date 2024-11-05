# frozen_string_literal: true

module Users
  class Offboard
    # inverse of onboard.
    # user becomes inactive or leaves network
    # disable google account
    # remove them from google groups
    # suspend profile
    # suspend school profile

    def initialize(user, school, end_date)
      @user = user
      @person = user.person
      @school = school
      @end_date = end_date
    end

    def run
      if @person
        @person.end_date = end_date
        @person.active = false
        @person.save!

        @person.school_relationships.where(school_id: @school.id).each do |sr|
          sr.end_date = end_date
          sr.save!
        end
      end

      @user.destroy!
    end
  end
end
