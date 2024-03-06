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

    acts_as_taggable_on :categories, :phase

  end
end
