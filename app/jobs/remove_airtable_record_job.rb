# frozen_string_literal: true

class RemoveAirtableRecordJob < ActiveJob::Base
  queue_as :default

  def perform(platform_airtable_id, table)
    Network::RemoveAirtableRecord.call(platform_airtable_id, table)
  end
end
