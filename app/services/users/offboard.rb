# frozen_string_literal: true

module Users
  class Offboard
    # inverse of onboard.

    def initialize(user, end_date)
      @user = user
      @person = user.person
      @end_date = end_date
    end

    def run
      if @person
        @person.active = false
        @person.end_date ||= @end_date
        @person.save!

        @person.assignments.incomplete.destroy_all

        @person.school_relationships.each do |sr|
          sr.end_date ||= @end_date
          sr.save!
        end
      end

      @user.destroy!
    end
  end
end
