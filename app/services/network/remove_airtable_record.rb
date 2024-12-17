# frozen_string_literal: true

require 'airtable/platform'

class Network::RemoveAirtableRecord < BaseCommand
  def initialize(platform_id, table)
    @platform_id = platform_id
    @table = table
  end

  def call
    record = @table.find(@platform_id)
    record&.destroy
  rescue Airrecord::Error => e
    Rails.logger.error("Error removing record id: #{@platform_id} from Airtable; Error: #{e.message}.")
    Highlight::H.instance.record_exception(e)
    if Rails.env.production?
      SlackClient.chat_postMessage(channel: '#circle-platform', text: "Error removing record id #{@platform_id} from airtable Airtable: #{e.message}",
                                   as_user: true)
    end
  end
end
