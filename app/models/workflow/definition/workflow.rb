module Workflow
  class Definition::Workflow < ApplicationRecord
    PHASES = ["visioning", "planning", "startup"]

    has_many :selected_processes
    has_many :processes, through: :selected_processes # these are the nodes

    has_many :dependencies # this loads the dependency edges

    has_many :instances, class_name: 'Workflow::Instance::Workflow', foreign_key: 'definition_id'


    # i need a workflow, its dependencies, to ask a processe who its prerequisites are.
    # I'm in a workflow.  I have a process.
    # I ask, the workflow, for this process, what are its dependencies
    # it loads dependencies, finds the process and sees its requisite.
    # and I only ask this to know if I'm startable...
    # so I don't care if its a process/step, if its not completed, its not done.
    # a step is done if its odne, and a process is done if its last step is done.
    # but this is all instance level logic.
  end
end
