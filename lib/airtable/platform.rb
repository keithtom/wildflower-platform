# frozen_string_literal: true

module Airtable
  class Platform
    PEOPLE = Airrecord.table(ENV.fetch('AIRTABLE_API_KEY', nil), 'appJBT9a4f3b7hWQ2', 'tbl8YaH13blJ0Znrb')
    SCHOOL = Airrecord.table(ENV.fetch('AIRTABLE_API_KEY', nil), 'appJBT9a4f3b7hWQ2', 'tblApPBFxTuFkZKSQ')
    SCHOOL_RELATIONSHIP = Airrecord.table(ENV.fetch('AIRTABLE_API_KEY', nil), 'appJBT9a4f3b7hWQ2', 'tblrz547zp5DrSW1e')
  end
end
