module Workflow
  class Definition::Process < ApplicationRecord
    has_many :instances, class_name: 'Workflow::Instance::Process', foreign_key: 'definition_id'

    has_many :steps

    has_many :selected_processes
    has_many :workflows, through: :selected_processes

    acts_as_taggable_on :categories
    enum effort: { small: 0, medium: 1, large: 2 }
  end
end
