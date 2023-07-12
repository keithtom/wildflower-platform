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
      # 'recNTCg3JTQJB7COu' => 'recdwpkVVp5qlaXm5'Maria Alcaraz (Ale) doesn't have an educator record that i could find in the filtered lists
      'recARYUZH7sIHE5jQ' => 'rechZWA30MRlZVSGF'
    }

    def initialize(source_csv)
      @source_csv = source_csv
      @csv = CSV.parse(@source_csv, headers: true, header_converters: [:downcase, :symbol], encoding: "ISO8859-1")
    end

    def import
      updates = 0
      creates = 0
      @csv.each do |row|
        next if SKIP_RECORDS.include?(row[:record_id])
        next if row[:currently_active] == "Inactive"

        if PARTNER_EDUCATORS.keys.include?(row[:record_id])
          # merge
          educator_id = PARTNER_EDUCATORS[row[:record_id]]
          if person = Person.find_by(:airtable_id => educator_id)
            updates += 1
            person.airtable_partner_id = row[:record_id]
            person.save!
            merge_roles(person, row)
          else
            # not found in educator table.
            raise "#{educator_id} not found but was expected; did you import educators yet?"
          end
        elsif person = Person.find_by(:airtable_partner_id => row[:record_id])
          updates += 1
          update_person(person, row)
        else
          creates += 1
          person = Person.create!(map_airtable_to_database(row))
          add_roles(person, row)
        end
      end
      puts "done; #{updates} updates, #{creates} creates"
    end


    private

    def map_airtable_to_database(airtable_row)
      hub = Hub.find_by(:name => airtable_row[:hub])
      pod = Pod.find_by(:name => airtable_row[:pod])

      {
        :airtable_partner_id => airtable_row[:record_id],
        :email => airtable_row[:email], # figure out if personal or wf
        :first_name => airtable_row[:name]&.split&.first,
        :last_name => airtable_row[:name]&.split&.last,
        :phone => airtable_row[:phone],
        :raw_address => airtable_row[:home_address],
        :hub => hub,
        :pod => pod,
        :start_date => airtable_row[:start_date_from_stints],
        :end_date => airtable_row[:end_date_from_stints],
        :image_url => airtable_row[:image_url],
      }
    end

    def update_person(person, airtable_row)
      person.email ||= airtable_row[:email]
      person.active = airtable_row[:currently_active]
      person.role_list = airtable_row[:roles].split(",").reject(&:blank?) if airtable_row[:roles].present?
      person.phone = airtable_row[:phone]
      person.raw_address = airtable_row[:home_address]
      # person.hub ||= Hub.find_by(:name => airtable_row[:hub])
      # person.pod ||= Pod.find_by(:name => airtable_row[:pod])
      person.start_date ||= airtable_row[:start_date_from_stints]
      person.end_date = airtable_row[:end_date_from_stints]
      person.image_url ||= airtable_row[:image_url]
      person.save!
    end

    def add_roles(person, airtable_row)
      if airtable_row[:roles].present?
        airtable_row[:roles].split(",").each do |tag|
          person.role_list.add(tag.strip) if tag.present?
        end
        person.save!
      end
    end

    def merge_roles(person, airtable_row)
      if airtable_row[:roles].present?
        airtable_row[:roles].split(",").each do |tag|
          person.role_list.add(tag.strip) if tag.present?
        end
        person.save!
      end
    end
  end
end
