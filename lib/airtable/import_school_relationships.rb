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
  # airtable view https://airtable.com/appJBT9a4f3b7hWQ2/shrOhalBugGlL9nyT/tbl8ww3ir5ngSTWe4

  def self.import_school_relationships
    link = "https://www.dropbox.com/scl/fi/eenfzm02uk3hvpznimq7m/Directory-launch-filter.csv?rlkey=r9gbosgetasstlqe1o3d8ktk9&dl=1"
    data = URI.parse(link).open.read
    data = data.force_encoding("UTF-8").gsub!("\xEF\xBB\xBF", '') # remove byte order marker
    Airtable::ImportSchoolRelationships.new(data).import
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
          school = SchoolRelationship.create!(map_airtable_to_database(row))
        end
      end
      puts "done; #{updates} updates, #{creates} creates"
    end


    private

    def map_airtable_to_database(airtable_row)
      school = School.find_by(:airtable_id => airtable_row[:school_record_id])
      if school.nil?
        raise "School not found for #{airtable_row[:school_record_id]}"
      end
      educator = Person.find_by(:airtable_id => airtable_row[:educator_record_id]) || create_educator(airtable_row)
      start_date = Date.strptime(airtable_row[:start_date], "%m/%d/%Y") rescue nil
      end_date = Date.strptime(airtable_row[:end_date], "%m/%d/%Y") rescue nil
      {
        :school => school,
        :person => educator,
        :name => airtable_row[:name],
        :start_date => start_date,
        :end_date => end_date,
        :airtable_id => airtable_row[:record_id]
      }
    end
  
    def create_educator(airtable_row)
      if person = Person.find_by(email: airtable_row[:educator_email])
        person.update!(airtable_id: airtable_row[:educator_record_id])
        return person
      end

      Person.create!(
        first_name: airtable_row[:educator_first_name],
        last_name: airtable_row[:educator_last_name],
        email: airtable_row[:educator_email],
        airtable_id: airtable_row[:educator_record_id]
      )
    end
  end
end
