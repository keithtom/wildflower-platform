module Workflow
  class Definition::Workflow < ApplicationRecord
    audited

    has_many :selected_processes
    has_many :processes, through: :selected_processes # these are the nodes

    has_many :steps, through: :processes

    has_many :dependencies # this loads the dependency edges

    has_many :instances, class_name: 'Workflow::Instance::Workflow', foreign_key: 'definition_id'
  end
end
