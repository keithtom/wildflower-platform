require 'csv'

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
  class ImportSchoolRelationships
    def initialize(source_csv)
      @source_csv = source_csv
      @csv = CSV.parse(@source_csv, headers: true, header_converters: [:downcase, :symbol])
    end

    def import
      @csv.each do |row|
        if school = SchoolRelationship.find_by(:airtable_id => row[:record_id])
          # update
          # Not implementing yet.
        else
          # create
          school = School.create!(map_airtable_to_database(row))
          add_ages_served(school, row)
          add_charter(school, row)
          add_tuition_assistance_types(school, row)
        end
      end
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
        :opened_on => opened_on,
        :airtable_id => airtable_row[:record_id]
      }
    end

    def add_ages_served(school, airtable_row)
      if airtable_row[:ages_served].present?
        school.ages_served_list = airtable_row[:ages_served]
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
