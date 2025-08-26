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
          return unless validate_dependency_creation

          return if validate_dependency_instance_already_exists

          create_dependency_instance
          @dependency_instance
        end

        def validate_dependency_creation
          find_prerequisite_workable if @prerequisite_workable.nil?
          find_workable_process if @workable_process.nil?
          @prerequisite_workable && @workable_process
        end

        def find_prerequisite_workable
          prerequisite_workable_definition = @dependency_definition.prerequisite_workable
          @prerequisite_workable = @wf_instance.processes.where(definition_id: prerequisite_workable_definition.id).first

          # during a rollout, it's possible the prerequisite was not updated because it was started.
          # therefore, use the original, unupdated prerequisite.
          while @prerequisite_workable.nil? && prerequisite_workable_definition.previous_version
            prerequisite_workable_definition = prerequisite_workable_definition.previous_version
            @prerequisite_workable = @wf_instance.processes.where(definition_id: prerequisite_workable_definition.id).first
          end

          return unless @prerequisite_workable.nil?

          Rails.logger.info("prerequisite_workable_definition: #{prerequisite_workable_definition.id}")
          Rails.logger.info("prerequisite workable not found for dependency def #{@dependency_definition.id} and workflow instance id #{@wf_instance.id}")
        end

        def find_workable_process
          workable_process_definition = @dependency_definition.workable
          @workable_process = @wf_instance.processes.where(definition_id: workable_process_definition.id).first

          # during a rollout, it's possible the workable was not updated because it was started.
          # therefore, use the original, unupdated workable.
          while @workable_process.nil? && workable_process_definition.previous_version
            workable_process_definition = workable_process_definition.previous_version
            @workable_process = @wf_instance.processes.where(definition_id: workable_process_definition.id).first
          end

          return unless @workable_process.nil?

          Rails.logger.info("workable not found for dependency def #{@dependency_definition.id} and workflow instance id #{@wf_instance.id}")
        end

        def validate_dependency_instance_already_exists
          if @dependency_definition.instances.exists?(
            workflow: @wf_instance,
            workable: @workable_process,
            prerequisite_workable: @prerequisite_workable
          )

            Rails.logger.info("dependency instance already exists for dependency def #{@dependency_definition.id} and workflow instance id #{@wf_instance.id}
            and workable id #{@workable_process.id} and prerequisite_workable id #{@prerequisite_workable.id}")

            return true
          end
          false
        end

        def create_dependency_instance
          @dependency_instance = @dependency_definition.instances.create!(
            workflow: @wf_instance,
            workable: @workable_process,
            prerequisite_workable: @prerequisite_workable
          )
        end
      end

      class CreateError < StandardError
      end
    end
  end
end
