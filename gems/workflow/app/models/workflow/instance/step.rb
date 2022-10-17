module Workflow
  class Instance::Step < ApplicationRecord
    belongs_to :definition, :class_name => 'Workflow::Definition::Step', foreign_key: 'workflow_definition_step_id'
    belongs_to :process, :class_name => 'Workflow::Instance::Process', foreign_key: 'workflow_instance_process_id'

    def step
      super || self.definition.step
    end

    def description
      super || self.definition.description
    end

    def type
      super || self.definition.type
    end

    def resource_url
      super || self.definition.resource_url
    end

    def resource_title
      super || self.definition.resource_title
    end
  end
end
