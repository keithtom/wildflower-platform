# frozen_string_literal: true

module Workflow
  module Instance
    class Dependency
      class Create < BaseService
        # this code assumes all workables are processes

        def initialize(dependency_definition, wf_instance, workable_process = nil, prereq_workable = nil)
          @dependency_definition = dependency_definition
          @wf_instance = wf_instance
          @workable_process = workable_process
          @prerequisite_workable = prereq_workable
          @dependency_instance = nil
        end

        def run
          find_prerequisite_workable if @prerequisite_workable.nil?
          find_workable_process if @workable_process.nil?
          create_dependency_instance
          return @dependency_instance
        end

        def find_prerequisite_workable
          prerequisite_process_id = @dependency_definition.prerequisite_workable_id
          @prerequisite_workable = @wf_instance.processes.where(definition_id: prerequisite_process_id).first
        end

        def find_workable_process
          workable_process_id = @dependency_definition.workable_id
          @workable_process = @wf_instance.processes.where(definition_id: workable_process_id).first
        end

        def create_dependency_instance
          @dependency_instance = @dependency_definition.instances.create!(
            workflow: @wf_instance,
            workable: @workable_process,
            prerequisite_workable: @prerequisite_workable
          )
        end
      end
    end
  end
end
