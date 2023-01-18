module Workflow
  class Instance::Process < ApplicationRecord
    include ApplicationRecord::ExternalIdentifier

    belongs_to :definition, class_name: 'Workflow::Definition::Process', optional: true # for manual steps
    belongs_to :workflow

    # use a service for this because prerequisites and post requisites is a mixed list of processes and steps.
    has_many :workable_dependencies, class_name: 'Workflow::Instance::Dependency', as: :workable # TODO: constrain me to the same workflow
    has_many :prerequisites, through: :workable_dependencies, source: :prerequisite_workable, source_type: 'Workflow::Instance::Process'

    has_many :prerequisite_dependencies, class_name: 'Workflow::Instance::Dependency', as: :prerequisite_workable
    has_many :postrequisites, through: :prerequisite_dependencies, source: :workable, source_type: 'Workflow::Instance::Process'

    has_many :steps, class_name: 'Workflow::Instance::Step'


    acts_as_taggable_on :categories
    enum effort: { small: 0, medium: 1, large: 2 }

    scope :by_position, -> { order("workflow_instance_processes.position ASC") }

    def title
      super || self.definition.title
    end

    def description
      super || self.definition.description
    end

    def effort
      super || self.definition.effort
    end

    def workflow_url
      self.workflow.url
    end

    def position
      super || self.definition.position
    end
  end
end
