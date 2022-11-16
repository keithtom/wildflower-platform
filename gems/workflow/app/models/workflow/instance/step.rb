module Workflow
  class Instance::Step < ApplicationRecord
    include ApplicationRecord::ExternalIdentifier

    belongs_to :definition, class_name: 'Workflow::Definition::Step', foreign_key: 'workflow_definition_step_id', optional: true
    belongs_to :process, class_name: 'Workflow::Instance::Process', foreign_key: 'workflow_instance_process_id'

    def title
      super || self.definition.try(:title)
    end

    def description
      self.definition.try(:description)
    end

    def kind
      super || self.definition.try(:kind)
    end

    def resource_url
      super || self.definition.try(:resource_url)
    end

    def resource_title
      super || self.definition.try(:resource_title)
    end

    def position
      super || self.definition.try(:position)
    end
  end
end
