module Workflow
  class Instance::Process < ApplicationRecord
    has_many :steps
    belongs_to :definition, :class_name => 'Workflow::Definition::Process', foreign_key: 'workflow_definition_process_id'
    belongs_to :workflow, :class_name => 'Workflow::Instance::Workflow', foreign_key: 'workflow_instance_workflow_id'

    acts_as_taggable_on :categories
    enum effort: { small: 0, medium: 1, large: 2 }

    def title
      super || self.definition.title
    end

    def description
      super || self.definition.description
    end

    def effort
      super || self.definition.effort
    end

    def weight
      super || self.definition.weight
    end
  end
end
