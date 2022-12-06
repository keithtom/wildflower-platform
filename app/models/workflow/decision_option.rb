module Workflow
  class DecisionOption < ApplicationRecord
    include ApplicationRecord::ExternalIdentifier

    belongs_to :decision, class_name: 'Workflow::Definition::Step'
    has_many :selections, class_name: 'Workflow::Instance::Step'

    def self.table_name_prefix
      "workflow_"
    end
  end
end
