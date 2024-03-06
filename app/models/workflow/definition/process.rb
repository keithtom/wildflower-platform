module Workflow
  class Definition::Process < ApplicationRecord
    DEFAULT_INCREMENT = 100
    
    audited
    
    has_many :instances, class_name: 'Workflow::Instance::Process', foreign_key: 'definition_id'

    has_many :steps

    has_many :selected_processes
    has_many :workflows, through: :selected_processes

    acts_as_taggable_on :categories, :phase

    accepts_nested_attributes_for :steps
  end
end
