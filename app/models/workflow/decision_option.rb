# Is this in the definition?
module Workflow
  class DecisionOption < ApplicationRecord
    include ApplicationRecord::ExternalIdentifier

    belongs_to :decision, class_name: 'Workflow::Definition::Step', foreign_key: 'decision_id', inverse_of: :decision_options

    def self.table_name_prefix
      "workflow_"
    end
  end
end
