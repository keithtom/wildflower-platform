module Workflow
  class Instance::Step < ApplicationRecord
    include ApplicationRecord::ExternalIdentifier

    belongs_to :definition, class_name: 'Workflow::Definition::Step'
    belongs_to :process

    def title
      super || self.definition.title
    end

    def description
      super || self.definition.description
    end

    def kind
      super || self.definition.kind
    end

    def resource_url
      super || self.definition.resource_url
    end

    def resource_title
      super || self.definition.resource_title
    end

    def position
      super || self.definition.position
    end
  end
end
