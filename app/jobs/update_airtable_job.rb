# frozen_string_literal: true

class UpdateAirtableJob < ActiveJob::Base
  queue_as :default

  def perform
    Network::UpdateAirtableRecords.call()
  end
end