require 'csv'
require 'open-uri'

# csv = CSV.parse(File.open('schools.csv'), headers:true, header_converters: [:downcase, :symbol])
# csv.headers

# production
# require 'open-uri'
# link = "https://www.dropbox.com/s/xwd4yi02st1flcb/educators.csv?dl=1"
# data = URI.parse(link).open.read
# data = data.force_encoding("UTF-8").gsub!("\xEF\xBB\xBF", '') # remove byte order marker
# Airtable::ImportEducators.new(data).import

module Airtable
  # In Airtable, this is "Educators x Schools"

  def self.import_schools
    csv = URI.open("https://www.dropbox.com/?dl=1").read
    # csv = CSV.parse(partners, headers:true, header_converters: [:downcase, :symbol])
    # csv.headers
    Airtable::ImportSchoolRelationships.new(csv).import
  end

  class ImportSchoolRelationships
    def initialize(source_csv)
      @source_csv = source_csv
      @csv = CSV.parse(@source_csv, headers: true, header_converters: [:downcase, :symbol])
    end

    def import
      updates = 0
      creates = 0
      @csv.each do |row|
        if school = SchoolRelationship.find_by(:airtable_id => row[:record_id])
          # Not implementing yet.
          updates += 1
        else
          creates += 1
          school = School.create!(map_airtable_to_database(row))
          add_ages_served(school, row)
          add_previous_names(school, row)
          add_charter(school, row)
          add_tuition_assistance_types(school, row)
        end
      end
      puts "done; #{updates} updates, #{creates} creates"
    end


    private

    def map_airtable_to_database(airtable_row)
      hub = Hub.find_by(:name => airtable_row[:hub])
      pod = Pod.find_by(:name => airtable_row[:pod])
      opened_on = Date.strptime(airtable_row[:opened], "%m/%d/%Y") rescue nil
      {
        :hub => hub,
        :pod => pod,
        :name => airtable_row[:name],
        :status => airtable_row[:school_status],
        :website => airtable_row[:website],
        :phone => airtable_row[:school_phone],
        :email => airtable_row[:school_email],
        :domain => airtable_row[:email_domain],
        :governance_type => airtable_row[:governance_model],
        :calendar => airtable_row[:school_calendar],
        :max_enrollment => airtable_row[:enrollment_at_full_capacity],
        :facebook => airtable_row[:facebook],
        :instagram => airtable_row[:instagram],
        :logo_url => airtable_row[:logo_url],
        :timezone => airtable_row[:time_zone],
        :raw_address => airtable_row[:address],
        :opened_on => opened,
        :airtable_id => airtable_row[:record_id],
        :about => airtable_row[:about],
        :about_es => airtable_row[:about_spanish],
        :hero_image_url => airtable_row[:hero_image_url],
        :hero_image2_url => airtable_row[:hero_image_2_url],
        :charter_string => airtable_row[:charter],
        # :closed_on => airtable_row[:closed],
        :affiliation_date => airtable_row[:affiliation_date],
        :num_classrooms => airtable_row[:number_of_classrooms],
      }
    end

    def add_ages_served(school, airtable_row)
      if airtable_row[:ages_served].present?
        airtable_row[:ages_served].split(",").each do |tag|
          school.ages_served_list.add(tag.strip) if tag.present?
        end
        school.save!
      end
    end

    def add_previous_names(school, airtable_row)
      if airtable_row[:prior_names].present?
        airtable_row[:prior_names].split(",").each do |tag|
          school.previous_names_list.add(tag.strip) if tag.present?
        end
        school.save!
      end
    end

    def add_charter(school, airtable_row)
      if airtable_row[:charter].present?
        school.charter_list = airtable_row[:charter]
        school.save!
      end
    end

    def add_tuition_assistance_types(school, airtable_row)
      if airtable_row[:sources_of_tuition_subsidy_ind_schools_only].present?
        school.tuition_assistance_type_list = airtable_row[:sources_of_tuition_subsidy_ind_schools_only]
        school.save!
      end
    end
  end
end
