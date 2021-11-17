# frozen_string_literal: true
require "application_record/external_identifier"

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
