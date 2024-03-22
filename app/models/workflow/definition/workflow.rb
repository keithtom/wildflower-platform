module Workflow
  class Definition::Workflow < ApplicationRecord
    audited

    has_many :selected_processes
    has_many :processes, through: :selected_processes # these are the nodes

    has_many :steps, through: :processes

    has_many :dependencies # this loads the dependency edges

    has_many :instances, class_name: 'Workflow::Instance::Workflow', foreign_key: 'definition_id'
    
    belongs_to :previous_version, class_name: 'Workflow::Definition::Workflow', foreign_key: 'previous_version_id', optional: true
    has_one :next_version, class_name: 'Workflow::Definition::Workflow', foreign_key: 'previous_version_id'
  
    def published?
      !published_at.nil?
    end
  end
end
