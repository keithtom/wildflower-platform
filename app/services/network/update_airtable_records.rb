class Network::UpdateAirtableRecords < BaseCommand
  PLATFORM_PEOPLE = Airrecord.table(ENV["AIRTABLE_API_KEY"], "appJBT9a4f3b7hWQ2", "tbl8YaH13blJ0Znrb")
  PLATFORM_SCHOOL = Airrecord.table(ENV["AIRTABLE_API_KEY"], "appJBT9a4f3b7hWQ2", "tblApPBFxTuFkZKSQ")
  PLATFORM_SCHOOL_RELATIONSHIP = Airrecord.table(ENV["AIRTABLE_API_KEY"], "appJBT9a4f3b7hWQ2", "tblrz547zp5DrSW1e")

  def call
    # Everyday, we want to sync the Airtable records with the latest data from the database.
    update_airtable("Educators", Person.tagged_with("Teacher Leader"), PLATFORM_PEOPLE, method(:people_fields))
    update_airtable("Partners", Person.where.not(airtable_partner_id: nil), PLATFORM_PEOPLE, method(:people_fields))
    update_airtable("Schools", School.all, PLATFORM_SCHOOL, method(:school_fields))
    update_airtable("School Relationships", SchoolRelationship.all, PLATFORM_SCHOOL_RELATIONSHIP, method(:school_relationship_fields))
  end

  private
  
  def update_airtable(name, query, airtable_table, field_func)
    begin
      # updates existing records
      updates = 0
      query.where.not(platform_airtable_id: nil).where("? > ?", :updated_at, :airtable_sync_at).each do |instance|
        record = airtable_table.find(instance.platform_airtable_id)
        field_func.call(instance).each do |key, value|
          record[key.to_s] = value
        end
        record.save
        instance.update_column(:airtable_sync_at, DateTime.now)
        updates += 1
        Rails.logger.info("Updated #{name} airtable record #{instance.platform_airtable_id} (#{instance.id})")
      end
      
      # creates new records
      creates = 0
      query.where(platform_airtable_id: nil).each do |instance|
        airtable_record = airtable_table.create(field_func.call(instance))
        instance.platform_airtable_id = airtable_record.id
        instance.save!
        instance.update_column(:airtable_sync_at, DateTime.now)
        creates += 1
        Rails.logger.info("Created #{name} airtable record #{instance.platform_airtable_id} (#{instance.id})")
      end
      Rails.logger.info("Finished syncing #{name} creates/updates to Airtable; #{updates} updates, #{creates} creates")
    rescue => e
      Rails.logger.error("Error syncing #{name} creates/updates to Airtable; #{updates} updates, #{creates} creates completed. Error: #{e.message}.")
      Highlight::H.instance.record_exception(e)
      SlackClient.chat_postMessage(channel: '#circle-platform', text: e.message, as_user: true) if Rails.env.production?
      raise e
    end
  end

  def people_fields(person)
    {
      :first_name => person.first_name,
      :middle_name => person.middle_name,
      :last_name => person.last_name,
      :email => person.email,
      :raw_address => person&.address&.full_address,
      :hub => person&.hub&.name,
      :pod => person&.pod&.name,
      :tc_user_id => person.tc_user_id,
      :prosperworks_id => person.prosperworks_id,
      :willing_to_relocate => person.willing_to_relocate,
      :primary_language => person.primary_language,
      :race_ethnicity_other => person.race_ethnicity_other,
      :household_income => person.household_income,
      :income_background => person.income_background,
      :gender => person.gender,
      :gender_other => person.gender_other,
      :lgbtqia => person.lgbtqia,
      :pronouns => person.pronouns,
      :pronouns_other => person.pronouns_other,
      :original_record_id => [person.airtable_id].compact, # airtable_id to the educators table, not the platform_educators table
      :stage => person.journey_state,
      :montessori_certified => person.montessori_certified,
      :languages => person.language_list.join(", "),
      :roles => person.role_list.join(", "),
      :race_ethnicity => person.race_ethnicity_list.join(", ")
    }
  end

  def school_fields(school)
    {
      :name => school.name,
      :hub => school&.hub&.name,
      :pod => school&.pod&.name,
      :status => school.status,
      :website => school.website,
      :phone => school.phone,
      :email => school.email,
      :email_domain => school.domain,
      :governance_model => school.governance_type,
      :calendar => school.calendar,
      :enrollment_at_full_capacity => school.max_enrollment,
      :facebook => school.facebook,
      :instagram => school.instagram,
      :logo_url => school.logo_url,
      :time_zone => school.timezone,
      :address => school&.address&.full_address,
      :opened_on => school.opened_on,
      :original_record_id => [school.airtable_id].compact, # airtable_id to the schools table, not the platform_schools_table
      :charter => school.charter_string,
      :about => school.about,
      :about_es => school.about_es,
      :hero_image_url => school.hero_image_url,
      :hero_image2_url => school.hero_image2_url,
      :affiliation_date => school.affiliation_date,
      :number_of_classrooms => school.num_classrooms
    }
  end

  def school_relationship_fields(school_relationship)
    {
        :name => school_relationship.name,
        :platform_school_record_id => [school_relationship&.school&.platform_airtable_id].compact,
        :platform_person_record_id => [school_relationship&.person&.platform_airtable_id].compact,
        :start_date => school_relationship.start_date,
        :end_date => school_relationship.end_date,
        :original_record_id => [school_relationship.airtable_id].compact # airtable_id to the school x relationship table, not the platform_schools_table
    }
  end
end