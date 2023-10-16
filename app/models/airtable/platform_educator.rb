Airrecord.api_key = ENV["AIRTABLE_API_KEY"]

# Person.where(teacher_leader_role: "Teacher Leader")

class PlatformEducator < Airrecord::Table
  self.base_key = "appJBT9a4f3b7hWQ2"
  self.table_name = "tbl8YaH13blJ0Znrb"

  def translate_from_person(person)
        {
          :hub => hub,
          :pod => pod,
          :first_name => person.first_name,
          :middle_name => person.last_name,
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
        }
  end
  
end