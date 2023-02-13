module Workflow
  class Definition::Process < ApplicationRecord
    DEFAULT_INCREMENT = 100

    has_many :instances, class_name: 'Workflow::Instance::Process', foreign_key: 'definition_id'

    has_many :steps

    has_many :selected_processes
    has_many :workflows, through: :selected_processes

    acts_as_taggable_on :categories, :phase
    enum effort: { small: 0, medium: 1, large: 2 }

    scope :by_position, -> { order("workflow_instance_processes.position ASC") }
  end
end
