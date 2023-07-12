require 'csv'
require 'open-uri'

# csv = CSV.parse(File.open('schools.csv'), headers:true, header_converters: [:downcase, :symbol])
# csv.headers

module Airtable

  def self.import_educators
    csv = URI.open("https://www.dropbox.com/scl/fi/qtiapwzyr6krei50tndlz/educators-filtered.csv?rlkey=rzlw43ehzup6ybsq5poujs0he&dl=1").read
    # csv = CSV.parse(partners, headers:true, header_converters: [:downcase, :symbol])
    # csv.headers
    Airtable::ImportEducators.new(csv).import
  end

  class ImportEducators

    # britni.haynie@tigerlilymontessori.org
    # alejandra@liriomontessori.org
    # megan.nicole.gardner@gmail.com
    # rocio.dew3@gmail.com

    SKIP_RECORDS = ['recfdtMDk0Dh9Qkyf', 'recfL1pGitx4NyGHL', 'recLgghNrlBhpzANW', 'recnUSke2rLNjD0Ly', 'rec1GnbjEMhKdQlfR'] # this record seems to be a useless dupe.

    def initialize(source_csv)
      @source_csv = source_csv
      @csv = CSV.parse(@source_csv, headers: true, header_converters: [:downcase, :symbol], encoding: "ISO8859-1")
    end

    def import
      updates = 0
      creates = 0

      @csv.each do |row|
        next if row[:mark_for_deletion].present?
        next if SKIP_RECORDS.include?(row[:record_id])

        if person = Person.find_by(:airtable_id => row[:record_id])
          puts "updating #{person.name}..."
          updates += 1
          update_person(person, row)
        else
          puts "creating #{row[:record_id]} = #{row[:first_name]} #{row[:last_name]}..."
          creates += 1
          person = Person.create!(map_airtable_to_database(row))
          add_tl_role(person)
          add_languages(person, row)
          add_race_ethnicity(person, row)
          add_relationships(person, row)
        end
      end

      puts "done; #{updates} updates, #{creates} creates"
    end


    private

    def map_airtable_to_database(airtable_row)
      hub = Hub.find_by(:name => airtable_row[:hub])
      pod = Pod.find_by(:name => airtable_row[:pod])

      # geocode raw_address to get address object populated
      # load contact info for each person to figure out personal email vs wf email, and phone
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
        :race_ethnicity_other => airtable_row[:race_ethnicity_other], # How is this imported? is key right?
        :household_income => airtable_row[:household_income],
        :income_background => airtable_row[:income_background],
        :gender => airtable_row[:gender],
        :gender_other => airtable_row[:gender_other],
        :lgbtqia => airtable_row[:lgbtqia] && airtable_row[:lgbtqia].strip.downcase == "true",
        :pronouns => airtable_row[:pronouns],
        :pronouns_other => airtable_row[:pronouns_other],
        :airtable_id => airtable_row[:record_id],
        :journey_state => airtable_row[:stage],
        :montessori_certified => airtable_row[:montessori_certified],
        # :affiliated_at => airtable_row[:affiliation_status].present? ? Time.parse("1/1/1") : nil,
      }
    end

    # TLs we don't really listen to airtable
    def update_person(person, airtable_row)
    end


    def add_tl_role(person)
      person.role_list.add("Teacher Leader")
      person.save!
    end

    def add_languages(person, airtable_row)
      if airtable_row[:languages].present?
        airtable_row[:languages].split(",").each do |tag|
          person.language_list.add(tag.strip) if tag.present?
        end
        person.save!
      end
    end

    # how is this imported... is the key right?
    def add_race_ethnicity(person, airtable_row)
      if airtable_row[:race_ethnicity].present?
        airtable_row[:race_ethnicity].split(",").each do |tag|
          person.race_ethnicity_list.add(tag.strip) if tag.present?
        end
        person.save!
      end
    end

    def add_relationships(people, airtable_row)
    end
  end
end