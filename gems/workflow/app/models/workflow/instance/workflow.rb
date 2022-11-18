module Workflow
  class Instance::Workflow < ApplicationRecord
    include ApplicationRecord::ExternalIdentifier

    belongs_to :definition, class_name: 'Workflow::Definition::Workflow'

    has_many :processes, class_name: 'Workflow::Instance::Process'
    has_many :dependencies

    def name
      self.definition.name
    end

    def description
      self.definition.description
    end

    def url
      "/v1/workflows/#{self.id}"
    end

    def version
      self.definition.version
    end
  end
end
