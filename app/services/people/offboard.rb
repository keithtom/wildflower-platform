# frozen_string_literal: true

module People
  class Offboard < BaseService
    def initialize(person, end_date)
      @person = person
      @user = person.user
      @end_date = end_date
    end

    def run
      @person.active = false
      @person.end_date ||= @end_date
      @person.save!

      @person.assignments.incomplete.destroy_all

      @person.school_relationships.each do |sr|
        sr.end_date ||= @end_date
        sr.save!
      end

      @user.destroy! if @user
    end
  end
end
