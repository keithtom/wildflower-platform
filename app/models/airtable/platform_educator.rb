Airrecord.api_key = ENV["AIRTABLE_API_KEY"]

# Person.where(teacher_leader_role: "Teacher Leader")

# tag = ActsAsTaggableOn::Tag.find_by(name: "Teacher Leader")
# p = tag.taggings.first.taggable

class PlatformEducator < Airrecord::Table
  self.base_key = "appJBT9a4f3b7hWQ2"
  self.table_name = "tbl8YaH13blJ0Znrb"


  def translate_from_person(person)
        {
          :first_name => person.first_name,
          :middle_name => person.middle_name,
          :last_name => person.last_name,
          :email => person.email,
          :raw_address => person&.address.full_address,
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
          :airtable_id => person.airtable_id,
          :stage => person.journey_state,
          :montessori_certified => person.montessori_certified,
        }
  end
end