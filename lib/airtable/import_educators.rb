require 'csv'

# csv = CSV.parse(File.open('schools.csv'), headers:true, header_converters: [:downcase, :symbol])
# csv.headers

module Airtable
  class ImportEducators

    # britni.haynie@tigerlilymontessori.org
    # alejandra@liriomontessori.org
    # megan.nicole.gardner@gmail.com
    # rocio.dew3@gmail.com

    SKIP_RECORDS = ['recfL1pGitx4NyGHL', 'recLgghNrlBhpzANW', 'recnUSke2rLNjD0Ly', 'rec1GnbjEMhKdQlfR'] # this record seems to be a useless dupe.

    def initialize(source_csv)
      @source_csv = source_csv
      @csv = CSV.parse(@source_csv, headers: true, header_converters: [:downcase, :symbol])
    end

    def import
      @csv.each do |row|
        next if row[:mark_for_deletion].present?
        next if SKIP_RECORDS.include?(row[:record_id])

        if person = Person.find_by(:airtable_id => row[:record_id])
          # Not implementing yet.
        else
          person = Person.create!(map_airtable_to_database(row))
          add_languages(person, row)
          add_race_ethnicity(person, row)
          add_relationships(person, row)
        end
      end
    end


    private

    def map_airtable_to_database(airtable_row)
      hub = Hub.find_by(:name => airtable_row[:hub])
      pod = Pod.find_by(:name => airtable_row[:pod])

      # geocode raw_address to get address object populated
      # load contact info for each person to figure out personal email vs wf email, and phone
      opened_on = Date.strptime(airtable_row[:opened], "%m/%d/%Y") rescue nil
      {
        :hub => hub,
        :pod => pod,
        :first_name => airtable_row[:first_name],
        :middle_name => airtable_row[:middle_name],
        :last_name => airtable_row[:last_name],
        :email => airtable_row[:contact_email], # figure out if personal or wf
        :raw_address => airtable_row[:home_address],
        :tc_user_id => airtable_row[:tc_user_id],
        :prosperworks_id => airtable_row[:prosperworks_id],
        :willing_to_relocate => airtable_row[:willing_to_relocate],
        :primary_language => airtable_row[:primary_language],
        :race_ethnicity_other => airtable_row[:race_ethnicity_other],
        :household_income => airtable_row[:household_income],
        :income_background => airtable_row[:income_background],
        :gender => airtable_row[:gender],
        :gender_other => airtable_row[:gender_other],
        :lgbtqia => airtable_row[:lgbtqia],
        :pronouns => airtable_row[:pronouns],
        :pronouns_other => airtable_row[:pronouns_other],
        :airtable_id => airtable_row[:record_id],
        :journey_state => airtable_row[:stage],

      }
    end

    def add_relationships(person, airtable_row)
      if airtable_row[:assigned_partner_record_id].present?
        # find that person in table, build relationship
        # other_person = Person.find_by(:airtable_id => airtable_row[:assigned_partner_record_id])

        # return unless other_person

        # return if PeopleRelationship.exist?(person: person, other_person: other_person, kind: PeopleRelationship::FOUNDATION_PARTNER)

        # PeopleRelationship.create!(person: person, other_person: other_person, kind: PeopleRelationship::FOUNDATION_PARTNER)

      end
    end

    def add_languages(person, airtable_row)
      if airtable_row[:languages].present?
        person.language_list = airtable_row[:languages]
        person.save!
      end
    end

    def add_race_ethnicity(person, airtable_row)
      if airtable_row[:race_ethnicity].present?
        person.race_ethnicity_list = airtable_row[:race_ethnicity]
        person.save!
      end
    end
  end
end
