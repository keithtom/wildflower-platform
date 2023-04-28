# Is this in the definition?
module Workflow
  class DecisionOption < ApplicationRecord
    include ApplicationRecord::ExternalIdentifier

    belongs_to :decision, class_name: 'Workflow::Definition::Step'

    def self.table_name_prefix
      "workflow_"
    end
  end
end
