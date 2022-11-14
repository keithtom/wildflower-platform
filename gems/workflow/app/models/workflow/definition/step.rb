module Workflow
  class Definition::Step < ApplicationRecord
    belongs_to :process
    has_many :instances, class_name: 'Workflow::Instance::Step', foreign_key: 'workflow_definition_step_id'
  end
end
