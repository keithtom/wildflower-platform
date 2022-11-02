require 'active_support/concern'

module Workflow
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    module ExternalIdentifier
      extend ActiveSupport::Concern

      included do
        before_create :set_external_identifier
        attr_readonly :external_identifier
      end

      def to_param
        external_identifier
      end

      private

      def generate_external_identifier
        "#{SecureRandom.hex(2)}-#{SecureRandom.hex(2)}"
      end

      def set_external_identifier
        return if external_identifier.present?

        loop do
          self.external_identifier = generate_external_identifier
          break unless self.class.exists?(external_identifier: external_identifier)
        end
      end
    end
  end
end
