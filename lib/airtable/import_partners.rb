require 'csv'

require 'open-uri'

module Airtable

  def self.import_partners
    partners = URI.open("https://www.dropbox.com/s/kjkjbq3cv9smyut/partners.csv?dl=1").read
    # csv = CSV.parse(partners, headers:true, header_converters: [:downcase, :symbol])
    # csv.headers
    Airtable::ImportPartners.new(partners).import
  end

  class ImportPartners
    SKIP_RECORDS = []
  
    # maps partner record id to educator record id
    PARTNER_EDUCATORS = {'recM4yBS6e9Mdm8HF' => 'reca83rZwZhmhJ6Vw',
      'recG6MmlihTqHgCIp' => 'recGxGi8NCUGxNi5Z',
      'recGmCNQRbt1gykBE' => 'recCytxzM8HwZjV7L',
      'recB690yYisuY19p9' => 'reczTEMEBfI0RHrfL',
      # 'recFebKuZ7W1SyyY5', # kanan doesn't have an educator record, even though she is one.
      'recf0ZdSpUO5mvAS1' => 'rec1wmxZ4ySlz30xR',
      'reckr1qf6IzId3PEU' => 'recaB9d3Khz3Qy6gl',
      'recMwTUEVYgzKEB92' => 'recEZ15MHkszY9wni',
      'recvlBDgX7Urljo4Q' => 'recW8izempocGpvef',
      'recNTCg3JTQJB7COu' => 'recdwpkVVp5qlaXm5',
      'recpRnZwLDp0D5Zek' => 'reccFU4hQjReOW41V',
    }

    def initialize(source_csv)
      @source_csv = source_csv
      @csv = CSV.parse(@source_csv, headers: true, header_converters: [:downcase, :symbol], encoding: "ISO8859-1")
    end

    def import
      @csv.each do |row|
        next if SKIP_RECORDS.include?(row[:record_id])

        if PARTNER_EDUCATORS.keys.include?(row[:record_id])
          # merge
          educator_id = PARTNER_EDUCATORS[row[:record_id]]
          if person = Person.find_by(:airtable_id => educator_id)
            person.airtable_partner_id = row[:record_id]
            person.save!
            merge_roles(person, row)
          else
            # not found in educator table.
            raise "#{educator_id} not found but was expected; did you import educators yet?"
          end
        elsif person = Person.find_by(:airtable_partner_id => row[:record_id])
          # Not implementing yet.  just a regular update of partner.
        else
          person = Person.create!(map_airtable_to_database(row))
          add_roles(person, row)
        end
      end
    end


    private

    def map_airtable_to_database(airtable_row)
      hub = Hub.find_by(:name => airtable_row[:hub])
      pod = Pod.find_by(:name => airtable_row[:pod])

      {
        :airtable_partner_id => airtable_row[:record_id],
        :email => airtable_row[:contact_email], # figure out if personal or wf
        :first_name => airtable_row[:name]&.split&.first,
        :last_name => airtable_row[:name]&.split&.last,
        :phone => airtable_row[:phone],
        :raw_address => airtable_row[:home_address],
        :hub => hub,
        :pod => pod
      }
    end

    def add_roles(person, airtable_row)
      if airtable_row[:roles].present?
        airtable_row[:roles].split(",").each do |tag|
          person.role_list.add(tag.strip)
        end
        person.save!
      end
    end

    def merge_roles(person, airtable_row)
      if airtable_row[:roles].present?
        airtable_row[:roles].split(",").each do |tag|
          person.role_list.add(tag.strip)
        end
        person.save!
      end
    end
  end
end
