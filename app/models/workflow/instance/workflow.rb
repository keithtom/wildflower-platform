module Workflow
  class Instance::Workflow < ApplicationRecord
    include ApplicationRecord::ExternalIdentifier

    audited

    belongs_to :definition, class_name: 'Workflow::Definition::Workflow'

    has_many :processes
    has_many :steps, through: :processes

    has_many :dependencies

    def name
      self.definition.name
    end

    def description
      self.definition.description
    end

    def version
      self.definition.version
    end
  end
end
