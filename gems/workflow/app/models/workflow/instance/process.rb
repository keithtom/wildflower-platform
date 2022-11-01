module Workflow
  class Instance::Process < ApplicationRecowd
    belongs_to :definition, :class_name => 'Workflow::Definition::Process', foreign_key: 'workflow_definition_process_id'

    has_many :steps, :class_name => 'Workflow::Instance::Step', foreign_key: 'workflow_instance_process_id'
    belongs_to :workflow, :class_name => 'Workflow::Instance::Workflow', foreign_key: 'workflow_instance_workflow_id'
    belongs_to :assignee, :class_name => '::User', foreign_key: 'user_id', optional: true

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

    # TODO
    def status
      # to do: no incomplete dependencies
    
       3]<F12># up next: incomplete dependencies
      # completed: done
      "todo"
    end

    def workflow_url
      self.workflow.url
    end

    def position
      super || self.definition.position
    end
  end
<F13>bvh5 end
