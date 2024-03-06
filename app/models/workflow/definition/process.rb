module Workflow
  class Definition::Process < ApplicationRecord
    DEFAULT_INCREMENT = 100
    
    audited
    
    has_many :instances, class_name: 'Workflow::Instance::Process', foreign_key: 'definition_id'

    has_many :steps
    accepts_nested_attributes_for :steps

    has_many :selected_processes
    has_many :workflows, through: :selected_processes
    accepts_nested_attributes_for :selected_processes

    has_many :workable_dependencies, class_name: 'Workflow::Definition::Dependency', as: :workable
    has_many :prerequisites, through: :workable_dependencies, source: :prerequisite_workable, source_type: 'Workflow::Definition::Process'
    accepts_nested_attributes_for :workable_dependencies

    acts_as_taggable_on :categories, :phase

  end
end
